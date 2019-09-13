# frozen_string_literal: true

class FileFingerprintsController < ApplicationController
  def index
    render json: JSONAPI::ResourceSerializer.new(FileFingerprintResource).serialize_to_hash(resources)
  end

  private

  def resources
    # @TODO: Shometimes `descendants` method is not showing all models
    # It's probably an autoload issue.
    models = ApplicationRecord.descendants.collect(&:name).map do |model_name|
      next if model_name.constantize.abstract_class?

      model_columns = if model_name.constantize.respond_to?(:file_fingerprint_attributes)
                        model_name.constantize.file_fingerprint_attributes
                      else
                        model_name.constantize.column_names
                      end
      FileFingerprint.new(model_name, model_columns)
    end
    models.compact!
    # @TODO: Add proper filters based on resource class
    models.select! { |model| model.model_name.downcase == params[:filter][:model_name].downcase } if params.key?(:filter) && params[:filter][:model_name].present?
    models.map! { |record| FileFingerprintResource.new(record, nil) }
  end
end
