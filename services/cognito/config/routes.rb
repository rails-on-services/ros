# frozen_string_literal: true

Ros::Cognito::Engine.routes.draw do
  devise_for :users, controllers: { sessions: 'sessions', confirmations: 'confirmations' }

  jsonapi_resources :identifiers
  jsonapi_resources :users
  jsonapi_resources :pools
  jsonapi_resources :endpoints
end
