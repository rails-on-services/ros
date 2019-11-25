# frozen_string_literal: true

Ros::Cognito::Engine.routes.draw do
  jsonapi_resources :chown_results
  jsonapi_resources :chown_requests, only: [:create]
  jsonapi_resources :identifiers
  jsonapi_resources :users
  jsonapi_resources :pools
  jsonapi_resources :endpoints
  jsonapi_resources :metabase_card_identifier_records, only: [:create]

  get '/metabase_token/:identifier' =>'metabase_token#show'
end
