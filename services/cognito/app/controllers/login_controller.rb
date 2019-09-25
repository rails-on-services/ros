# frozen_string_literal: true

class LoginController < ApplicationController
  # TODO: Move payload to LoginController Spec
  # {
  #   "data": {
  #     "type": "login",
  #     "attributes": {
  #       "primary_identifier": "f92a8503-7b33-42b0-939d-5f948d5422ac"
  #     }
  #   }
  # }

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def create
    # Get the user from the payload
    json = request.body.read
    # TODO: use controller concern jsonapi_params
    pi = JSON.parse(json)['data']['attributes']['primary_identifier']

    unless (user = User.find_by(primary_identifier: pi))
      # TODO: Create a controller concern method and use that to render
      # It should take the status (401), code (:unauthorized) and the title as params
      # title param if nil defaults to code.to_s.capitalize
      render(status: :unauthorized, json: { errors: [{ status: '401', code: :unauthorized, title: 'Unauthorized' }] })
      return
    end

    # Add the 'sub_cognito' claim to the JWT and set the header
    current_jwt.add_claims('sub_cognito' => user.to_urn)
    current_jwt.add_claims('act_cognito' => user)

    # Render some body back to the client
    # TODO: Use controller concern serialize_resource to render
    render(status: :ok, json: { 'data': [{
             'type': 'login',
             'id': user.id,
             'attributes': {
               'jwt': current_jwt.encode
             },
             'links': {
               'self': 'http://example.com/things/1'
             }
           }] })
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end
