# frozen_string_literal: true

Ros::Organization::Engine.routes.draw do
  jsonapi_resources :branches
  jsonapi_resources :orgs
end
