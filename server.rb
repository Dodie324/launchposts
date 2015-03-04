require 'sinatra'
require 'pg'
require 'csv'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: "launchposts")
    yield(connection)
  ensure
    connection.close
  end
end

def add_new_post(params)
  post = [params["topic_id"], params["title"], params["url"], params["description"]]
  db_connection do |conn|
    conn.exec_params( "INSERT INTO posts (topic_id, title, url, description) 
                       VALUES ($1, $2, $3, $4)", post )
  end
end

def display_post(id)
  db_connection { |conn| conn.exec( "SELECT title, url, description
                                     FROM posts
                                     WHERE topic_id = #{id}
                                     ORDER BY post_date DESC" ) }
end

##########
# ROUTES #
##########

get '/' do
  redirect '/posts'
end

get '/posts' do
  erb :index
end

get '/posts/new' do
  erb :new
end

get '/posts/:topic' do

  erb :show, locals: { task_name: params[:task_name] }
end


get '/posts/ruby' do
  ruby_posts = display_post(1)
  erb :ruby, locals: { ruby: ruby_posts }
end

get '/posts/html_css' do
  html_css_posts = display_post(2)
  erb :html_css, locals: { html_css: html_css_posts }
end

get '/posts/javascript_jquery' do
  javascript_jquery_posts = display_post(3)
  erb :javascript_jquery, locals: { javascript_jquery: javascript_jquery_posts }
end

get '/posts/sql' do
  sql_posts = display_post(4)
  erb :sql, locals: { sql: sql_posts }
end

get '/posts/misc' do
  misc_posts = display_post(5)
  erb :misc, locals: { misc: misc_posts }
end

post '/posts/new' do
  add_new_post(params)
  redirect '/posts'
end
