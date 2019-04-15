# frozen_string_literal: true

Rails.application.routes.draw do
  extend Ros::Routes
  mount Ros::Core::Engine => '/'
  mount Ros::Cognito::Engine => '/'
  post '/login', to: 'login#create'
  catch_not_found
end
