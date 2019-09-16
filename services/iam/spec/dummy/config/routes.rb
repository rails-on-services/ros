# frozen_string_literal: true

Rails.application.routes.draw do
  extend Ros::Routes
  mount Ros::Core::Engine => Ros.dummy_mount_path
  mount Ros::Iam::Engine => Ros.dummy_mount_path
  catch_not_found
end
