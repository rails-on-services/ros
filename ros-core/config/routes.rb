# frozen_string_literal: true

Ros::Core::Engine.routes.draw do
  root to: proc { [404, { 'Content-Type' => 'application/vnd.api+json' },
                   [{ errors: [{ status: '404', title: 'Not found' }] }.to_json]] }
  jsonapi_resources :tenants
end
