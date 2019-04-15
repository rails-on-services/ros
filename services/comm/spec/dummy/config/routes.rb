# frozen_string_literal: true

Rails.application.routes.draw do
  extend Ros::Routes
  mount Ros::Core::Engine => '/'
  mount Ros::Comm::Engine => '/'
  catch_not_found
end
