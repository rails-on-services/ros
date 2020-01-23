# frozen_string_literal: true

Ros::Iam::Engine.routes.draw do
  jsonapi_resources :public_keys
  devise_for :users, module: 'users', defaults: { format: :json }

  jsonapi_resources :credentials
  jsonapi_resources :groups
  jsonapi_resources :policies
  jsonapi_resources :roots
  jsonapi_resources :users

  # TODO: temporary route until we support registering callbacks to allow
  # a root owner account to create a tenant
  post '/blackcomb_credentials', to: 'credentials#blackcomb'
end
