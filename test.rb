require 'rubygems'
require 'flowdock'

# Create a client that uses you api token to authenticate
# client = Flowdock::Client.new(api_token: '354d0b473ac5ce3aa07d6b7d9e9c6aa4')

flow_id = '48f1337b972e0bd66c47f58fb4899877'

flow = Flowdock::Flow.new(:api_token => flow_id, :external_user_name => "Dodie")

flow.push_to_chat(:content => "Hello!", :tags => ["LaunchPosts"])