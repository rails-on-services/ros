# frozen_string_literal: true

module Mailchimp
  class CreateListOperation
    attr_reader :audience
    delegate :name, :company_name, :address, :city, :state, :zip, :country, :phone, :reminder,
             :from_name, :from_email, :subject, :language, to: :audience

    def initialize(audience)
      @audience = audience
    end

    def request
      audience.validate!
      list_hash
    end

    private

    def list_hash
      {
        name: name,
        contact: contact_hash,
        permission_reminder: reminder,
        campaign_defaults: defaults_hash,
        email_type_option: true
      }
    end

    def contact_hash
      {
        company: company_name || '',
        address1: address || '',
        city: city || '',
        state: state || '',
        zip: zip || '',
        country: country || '',
        phone: phone || ''
      }
    end

    def defaults_hash
      {
        from_name: from_name,
        from_email: from_email,
        language: language,
        subject: subject || ''
      }
    end

  end
end