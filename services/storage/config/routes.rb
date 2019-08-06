# frozen_string_literal: true

Rails.application.routes.draw do
  jsonapi_resources :uploads
  jsonapi_resources :column_maps
  jsonapi_resources :transfer_maps
end
