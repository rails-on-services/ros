# frozen_string_literal: true

Ros::Cognito::Engine.routes.draw do
  devise_for :users, controllers: { sessions: 'sessions' }
  #devise_for :users#, controllers: { sessions: 'sessions' }, defaults: { format: :json }

  jsonapi_resources :identifiers
  jsonapi_resources :users
  jsonapi_resources :pools
  jsonapi_resources :endpoints
end
