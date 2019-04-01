# frozen_string_literal: true

class UserResourceDoc < ApplicationDoc
  route_base 'users'
  # route_base '/users'
  # route_base 'resources/user_resource'
  # route_base '/credentials'
  # api_dry :all do
  #   auth :Authorization
  # end

  # japi_dry %i[ index update destroy roles permissions roles_modify ] do
  # j  auth :Authorization
  # jend

  api :index, 'GET list of users' do #, builder: :index#, use: [:page, :rows]
    query 'page[number]', Integer  #, range: { ge: 1 }, default: 1
    query 'page[size]', Integer  #, range: { ge: 1 }, default: 1
    query :filter, String #, range: { ge: 1 }, default: 1
    query :sort, String #, range: { ge: 1 }, default: 1
    response 200, :success, 'application/vnd.api+json', data: { data: [{id: 1}] }
    response 401, :unauthorized, 'application/vnd.api+json', data: { data: [{id: 1}] }
  end

  api :show, 'GET the specified user'#, builder: :show#, use: id
=begin
  api :show_via_name, 'GET the specified user by name' do
    path! :name, String, desc: 'user name'
  end

  api :login, 'POST user login' do
    form! data: {
            :name! => String,
        :password! => String
    }

    response 0, 'success', :json, data: { data: { token: 'jwt token' } }
  end
=end

  api :create, 'POST user register' do
    form! data: {
      username!: String,
      password!: String,
      password_confirmation!: String
    }, pmt: true
  end

  api :update, 'PATCH|PUT update the specified user' do
    form! data: {
      username: String,
      password: String,
      password_confirmation: String
    }, pmt: true
  end

api :destroy, 'DELETE the specified user'


end

