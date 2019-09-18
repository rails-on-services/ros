# frozen_string_literal: true

Storage::Engine.routes.draw do
  jsonapi_resources :uploads
  jsonapi_resources :column_maps, only: [:index, :create]
  jsonapi_resources :transfer_maps, only: [:index, :show, :create]
end
