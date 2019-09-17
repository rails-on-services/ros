# frozen_string_literal: true

Storage::Engine.routes.draw do
  jsonapi_resources :uploads
  jsonapi_resources :column_maps
  jsonapi_resources :transfer_maps
  jsonapi_resources :files, only: %i[index create]
end
