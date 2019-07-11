# frozen_string_literal: true

Storage::Engine.routes.draw do
  jsonapi_resources :files, only: %i[index create]
end
