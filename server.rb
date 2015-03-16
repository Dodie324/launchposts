require 'sinatra'
require 'pg'
require 'flowdock'
require 'dotenv'
require 'httparty'

Dotenv.load

POSTS_PER_PAGE = 5

use Rack::Session::Cookie, {
  expire_after: 2592000, secret: ENV["SESSION_SECRET"]
}

###################
##### HELPERS #####
###################

def db_connection
  begin
    connection = PG.connect(dbname: "launchposts")
    yield(connection)
  ensure
    connection.close
  end
end

helpers do
  def current_user
    session[:username]
  end

  def user_signed_in?
    !current_user.nil?
  end
end

###################
##### SIGN IN #####
###################

get "/sign_out" do
  session[:username] = nil
  redirect "/"
end

get "/sign_in" do
  redirect "https://www.flowdock.com/oauth/authorize?client_id=#{ENV["CLIENT_ID"]}&redirect_uri=http%3A%2F%2Flocalhost%3A4567%2Fcallback&response_type=code"
end

get "/callback" do
  uri = URI("https://api.flowdock.com/oauth/token")

  res = Net::HTTP.post_form(uri, {
    "client_id" => ENV["CLIENT_ID"],
    "client_secret" => ENV["CLIENT_SECRET"],
    "code" => params["code"],
    "redirect_uri" => "http://localhost:4567/callback",
    "grant_type" => "authorization_code"
  })

  body = JSON.parse(res.body)
  access_token = body["access_token"]
  uri = URI("https://api.flowdock.com/user?access_token=#{access_token}")
  res = Net::HTTP.get(uri)
  profile = JSON.parse(res)
  session[:username] = profile["nick"]

  redirect "/posts"
end

###################
##### QUERIES #####
###################

def add_new_post(params)
  post = [params["title"], params["url"], params["description"], params["topic"]]
  db_connection do |conn|
    conn.exec_params( "INSERT INTO posts (title, url, description, post_date, topic_id)
                       VALUES ($1, $2, $3, CURRENT_TIMESTAMP, $4)", post)
  end
end

def post_topic
  sql = "SELECT topic, id FROM web_development ORDER BY id"
  topics = db_connection { |conn| conn.exec( sql ) }
end

def display_post(topic_id, offset)
  sql = "SELECT web_development.topic, posts.title, posts.url, posts.description
         FROM posts
         JOIN web_development ON web_development.id = posts.topic_id
         WHERE web_development.id = ($1)
         ORDER BY post_date DESC
         LIMIT ($2)
         OFFSET ($3)"
  post = db_connection { |conn| conn.exec( sql, [topic_id, POSTS_PER_PAGE, offset] ) }.to_a
end

def get_id
  sql = "SELECT id FROM web_development"
  ids = db_connection { |conn| conn.exec( sql ) }
end

######################
##### VALIDATORS #####
######################

def valid_post?(params)
  !params["title"].empty? && !params["url"].empty? && !params["description"].empty? && !valid_url?(params["url"])
end

def valid_url?(url)
  sql = "SELECT url FROM posts WHERE url = ($1)"
  url = db_connection { |conn| conn.exec( sql, [url] ) }

  !url.to_a.empty?
end

def post_to_params(params)
  param_string = "?"
  params.each do |key, value|
    param_string << "#{key}=#{value}&"
  end

  param_string
end

def get_error_message(params)
  error_mess = []

  if params["title"] == "" || params["url"] == "" || params["description"] == ""
    error_mess << "All fields must be filled out."
  elsif valid_url?(params["url"])
    error_mess << "URL already exists."
  end

  error_mess
end

def posts_per(topic_id, page)
  offset = (page.to_i) * POSTS_PER_PAGE
  display_post(topic_id, offset)
end

##################
####  ROUTES  ####
##################

get '/' do
  redirect '/posts'
end

get '/posts' do
  topics = post_topic
  erb :index, locals: { topics: topics }
end

get '/posts/new' do
  if params.empty?
    error_message = ''
  else
    error_message = get_error_message(params)
  end

  erb :new, locals: { errors: error_message }
end

get '/posts/:topic.json' do
  content_type :json
  posts_per(params["topic"], params[:page]).to_json
end

get '/posts/:topic' do
  topic = posts_per(params["topic"], 0)

  erb :show, locals: { topic: topic }
end

post '/posts/new' do
  if valid_post?(params)
    add_new_post(params)

    #Flowdock implementation
    flow = Flowdock::Flow.new(
      :api_token => ENV['FLOW_ID'],
      :source => "new_post",
      :external_user_name => session[:username])

    flow.push_to_chat(:content => "I've just uploaded a new LaunchPost: #{params["title"]} - #{params["url"]}")

    redirect '/posts'
  else
    error_message = get_error_message(params)
  end
    erb :new, locals: { errors: error_message }
end



