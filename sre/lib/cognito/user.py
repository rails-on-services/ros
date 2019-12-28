import json

def create_cognito_user(self, identifier, pool_id, header, anonymous=False):
  if anonymous:
    payload = { "data": { "type": "users", "attributes": { "primary_identifier": identifier, 'anonymous': True } } }
  else:
    payload = { "data": { "type": "users", "attributes": { "primary_identifier": identifier }, "relationships": { "pools": { "data": [{ "type": "pools", "id": pool_id }] } } } }

  return self.client.post('cognito/users', data=json.dumps(payload), headers=header )

def login_cognito_user(self, identifier, header, anonymous=False):
  payload = { "data": { "attributes": { "primary_identifier": identifier } } }
  login_response = self.client.post('cognito/login', data=json.dumps(payload), headers=header )

  header =  { "authorization": login_response.headers['Authorization'], 'content-type': 'application/vnd.api+json' }
  if anonymous:
    self.anonymous_header = header
  else:
    self.cognito_header = header
