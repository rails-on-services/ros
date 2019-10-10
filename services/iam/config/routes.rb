# frozen_string_literal: true

Ros::Iam::Engine.routes.draw do
  devise_for :users, module: 'users', defaults: { format: :json }
  devise_for :roots, module: 'roots', defaults: { format: :json }

  jsonapi_resources :roots
  jsonapi_resources :users
  jsonapi_resources :credentials
  jsonapi_resources :groups
  jsonapi_resources :policies
end
