# frozen_string_literal: true

class GroupResourceDoc < ApplicationDoc
  route_base 'groups'

  api :index, 'All Groups'
  api :show, 'Single Group'
  api :create, 'Create Group'
  api :update, 'Update Group'

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
