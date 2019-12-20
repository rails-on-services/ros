# frozen_string_literal: true

Storage::Engine.routes.draw do
  jsonapi_resources :column_maps
  jsonapi_resources :documents
  jsonapi_resources :images, only: %i[index show create]
  jsonapi_resources :reports, only: %i[index show]
  jsonapi_resources :transfer_maps
end
