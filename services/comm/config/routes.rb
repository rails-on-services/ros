# frozen_string_literal: true

Ros::Comm::Engine.routes.draw do
  jsonapi_resources :providers
  jsonapi_resources :campaigns
  jsonapi_resources :templates
  jsonapi_resources :events
  jsonapi_resources :messages
  jsonapi_resources :whatsapps
  mount Ros::Comm::Engine.server => Ros::Comm.cable.mount_path
end
