# frozen_string_literal: true

Storage::Engine.routes.draw do

  jsonapi_resources :uploads, only: %i[index create]
end
