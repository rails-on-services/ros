# frozen_string_literal: true

Ros::Cognito::Engine.routes.draw do
  jsonapi_resources :identifiers
  jsonapi_resources :users
  jsonapi_resources :pools
  jsonapi_resources :endpoints
end
