# frozen_string_literal: true

Rails.application.routes.draw do
  extend Ros::Routes
  mount Ros::Core::Engine => Ros.dummy_mount_path
  mount Ros::Cognito::Engine => Ros.dummy_mount_path
  post '/login', params: { to: 'login#create' }
  catch_not_found
end
