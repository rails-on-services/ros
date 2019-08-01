# frozen_string_literal: true

Ros::Comm::Engine.routes.draw do
  jsonapi_resources :providers
  jsonapi_resources :campaigns do
    resources :audience
    resources :email_campaigns do
      member do
        get :status
        get :content
        post :start
      end
    end
  end
  jsonapi_resources :templates
  jsonapi_resources :events
  jsonapi_resources :messages
  jsonapi_resources :whatsapps
end
