# frozen_string_literal: true

Ros::Iam::Engine.routes.draw do
  # devise_for :users, controllers: { sessions: 'users/sessions' }, defaults: { format: :json }
  # devise_for :roots, controllers: { sessions: 'roots/sessions' }, defaults: { format: :json }
  # devise_for :users, defaults: { format: :json }

  jsonapi_resources :roots
  jsonapi_resources :users
  jsonapi_resources :credentials
end
