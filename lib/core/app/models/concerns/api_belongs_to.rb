# frozen_string_literal: true

module ApiBelongsTo
  # NOTE: Allows microservices to talk to each other using the api-client library
  # fail ArgumentError,
  #  "Column #{model_id} does not exist on #{name}" unless column_names.include?(foreign_key_column)
  extend ActiveSupport::Concern

  class_methods do
    # Reads a GID, caches and returns the result with a simple declaration
    # Example: api_belongs_to :user, class_name: 'Ros::IAM::User'
    def api_belongs_to(model_name, class_name: nil, foreign_key: nil, polymorphic: nil, attr_id: nil)
      model_name = model_name.to_s
      class_name = class_name || model_name.classify
      attr_type = polymorphic ? "#{model_name}_type" : model_name
      attr_id = attr_id || "#{model_name}_id"
      gid_name = "#{model_name}_gid"

      # defines a method that returns a GlobalID in format: gid://internal/Service::Model/:id
      # Example: api_belongs_to :user, class_name: 'Ros::IAM::User'
      # creates a method named #user_gid that returns a GlobalID representing that instance's gid referencing :user
      define_method(gid_name) do
        current_id = send(attr_id)&.to_s
        unless instance_variable_get("@#{gid_name}")&.model_id == current_id
          gid_string = "gid://internal/#{polymorphic ? send(attr_type) : class_name}/#{current_id}"
          instance_variable_set("@#{gid_name}", current_id.blank? ? nil : GlobalID.new(gid_string))
        end
        instance_variable_get("@#{gid_name}")
      end

      # defines a method that returns a model from a remote service
      # Example: api_belongs_to :user, class_name: 'Ros::IAM::User'
      # creates a method named #user that returns an object from the GlobalID
      define_method(model_name) do
        current_id = send(attr_id)&.to_s
        unless instance_variable_get("@#{model_name}")&.id == current_id
          instance_variable_set("@#{model_name}", current_id.blank? ? nil : GlobalID::Locator.locate(send(gid_name)).first)
        end
        instance_variable_get("@#{model_name}")
      end

      # defines a method that takes an object and updates the associated _id and _gid values
      # Example: api_belongs_to :user, class_name: 'Ros::IAM::User'
      # creates a method named #user= that takes an object of type Ros::IAM::User and sets it on the model
      define_method("#{model_name}=") do |obj|
        fail ArgumentError, "Must be of type #{obj}" unless polymorphic || obj.class.name.eql?(class_name)
        send("#{attr_id}=", obj.id)
        send("#{attr_type}=", obj.class.name) if polymorphic
        instance_variable_set("@#{model_name}", obj)
        instance_variable_set("@#{gid_name}", obj.to_gid)
      end
    end
  end
end
