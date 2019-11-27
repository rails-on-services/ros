# frozen_string_literal: true

Ros::Cognito::Engine.routes.draw do
  jsonapi_resources :metabase_cards
  jsonapi_resources :chown_results
  jsonapi_resources :chown_requests, only: [:create]
  jsonapi_resources :identifiers
  jsonapi_resources :users
  jsonapi_resources :pools
  jsonapi_resources :endpoints

  resources :metabase_token, only: [:show]
end
