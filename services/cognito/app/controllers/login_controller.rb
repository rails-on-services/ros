# frozen_string_literal: true

class LoginController < ApplicationController

  def create
    # Get the user from the payload
    json = request.body.read
    pi = JSON.parse(json)['data']['attributes']['primary_identifier']

    unless user = User.find_by(primary_identifier: pi)
      render(status: :unauthorized, json: { errors: [{ status: '401', code: :unauthorized, title: 'Unauthorized' }]})
      return
    end

    # Add the 'sub_cognito' claim to the JWT and set the header
    current_jwt.add_claims('sub_cognito' => user.to_urn)

    # Render some body back to the client
    render(status: :ok, json: { 'data': [{
      'type': 'login',
      'id': user.id,
      'attributes': {
        'jwt': current_jwt.encode,
      },
      'links': {
        'self': 'http://example.com/things/1'
      }
    }]})
  end
end

=begin
{ 
  "data": {
    "type": "login",
    "attributes": {
      "primary_identifier": "f92a8503-7b33-42b0-939d-5f948d5422ac"
    }
  }
}
=end
