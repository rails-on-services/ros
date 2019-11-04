# frozen_string_literal: true

Ros::Cognito::Engine.routes.draw do
  jsonapi_resources :identifiers
  jsonapi_resources :users do
    member do
      post :merge #, controller: 'users/merge', action: 'create'
    end
  end
  jsonapi_resources :pools
  jsonapi_resources :endpoints

  resources :metabase_token, only: :show
end
