# frozen_string_literal: true

Ros::Core::Engine.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  # Respond with 200 to Kubernetes health check
  get 'healthz', to: proc { [200, {'Content-Type' => 'text/plain'}, ['']] }
  root to: proc { [404, { 'Content-Type' => 'application/vnd.api+json' },
                   [{ errors: [{ status: '404', title: 'Not found' }] }.to_json]] }
  jsonapi_resources :tenants
end
