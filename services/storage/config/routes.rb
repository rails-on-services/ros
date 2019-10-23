# frozen_string_literal: true

Storage::Engine.routes.draw do
  jsonapi_resources :documents, only: %i[index show create update]
  jsonapi_resources :images, only: %i[index show create]
  jsonapi_resources :reports, only: %i[index show]
  jsonapi_resources :transfer_maps
  jsonapi_resources :column_maps
end
