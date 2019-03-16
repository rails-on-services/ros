#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'

host = ARGV[0] || 'http://localhost:3000'
endpoint = ARGV[1] || 'users/sign_in'
uri = URI.parse "#{host}/#{endpoint}"

header = { 'Content-Type': 'application/json' }
user = {
  user: {
    tenant: 'test2',
    email: 'email@test2.com',
    password: 'abcd1234'
  }
}

http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Post.new(uri.request_uri, header)
request.body = user.to_json

# Send the request
response = http.request(request)
puts response.body

# Net::HTTP.post_form("http://#{host}/users/sign_in",
#                    "user" => { "email": "email@test1.com", "password": "abcd1234" }
#                   )
# %x(curl -X POST -v -H 'Content-Type: application/json' http://#{host}/users/sign_in -d '{"user" : {"email": "email@test1.com", "password": "abcd1234" }}')
