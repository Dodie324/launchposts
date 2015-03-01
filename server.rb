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
  post = [params["title"], params["url"], params["description"]]
  db_connection do |conn|
    conn.exec_params( "INSERT INTO posts (id, title, url, description, language_id) VALUES (DEFAULT, $1, $2, $3, DEFAULT)", post )
  end
end

##########
# ROUTES #
##########

get '/posts' do
  erb :index
end

get '/posts/new' do
  erb :new
end

post '/posts/new' do
  add_new_post(params)
  redirect '/posts'
end
