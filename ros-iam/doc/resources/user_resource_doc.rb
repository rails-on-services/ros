# frozen_string_literal: true

class UserResourceDoc < ApplicationDoc
  route_base 'users'
  # route_base '/users'
  # route_base 'resources/user_resource'
  # route_base '/credentials'
  # api_dry :all do
  #   auth :Authorization
  # end

  api_dry %i[ index ] do
    query 'page[number]', Integer  #, range: { ge: 1 }, default: 1
    query 'page[size]', Integer  #, range: { ge: 1 }, default: 1
    query :filter, String #, range: { ge: 1 }, default: 1
    query :sort, String #, range: { ge: 1 }, default: 1  end
  end

  api :index, 'GET list of users' do #, builder: :index#, use: [:page, :rows]
    dry
    response 200, :success, 'application/vnd.api+json', data: { data: [{id: 1}] }
    response 401, :unauthorized, 'application/vnd.api+json', data: { data: [{id: 1}] }
  end

#   api :show, 'GET the specified user' do #, builder: :show#, use: id
#     query 'id', Integer  #, range: { ge: 1 }, default: 1
#     response 200, :success, 'application/vnd.api+json', data: { data: [{id: 1}] }
#   end
#   api :create, 'POST user register' do
#     form! data: {
#       username!: String,
#       password!: String,
#       password_confirmation!: String
#     }, pmt: true
#   end

#   api :update, 'PATCH|PUT update the specified user' do
#     form! data: {
#       username: String,
#       password: String,
#       password_confirmation: String
#     }, pmt: true
#   end

# api :destroy, 'DELETE the specified user'


end