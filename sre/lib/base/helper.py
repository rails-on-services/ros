import json
import pdb
import os
from faker import Faker

def create_iam_user(self):
  payload =  { "data": { "type": "users", "attributes": { "username": Faker().name(), "time_zone": "SGT" } } }
  self.client.post('iam/users', data=json.dumps(payload), headers=self.iam_header)

def login_as_iam_user(self):
  payload = { "data": { "attributes": { "account_id": "generic", "username": "Admin", "password": "asdfjkl;" } } }
  return self.client.post('iam/users/sign_in', data=json.dumps(payload), headers={'content-type': 'application/json'})

def create_cognito_pool(self):
  pool_name = Faker().pystr()
  payload = { "data": { "type": "pools", "attributes": { "name": pool_name } } }
  return self.client.post('cognito/pools', data=json.dumps(payload), headers=self.iam_header )

def create_cognito_user(self, identifier):
  payload =  { "data": { "type": "users", "attributes": { "primary_identifier": identifier }, "relationships": { "pools": { "data": [{ "type": "pools", "id": self.pool_id }] } } } }
  return self.client.post('cognito/users', data=json.dumps(payload), headers=self.iam_header )

def login_cognito_user(self, identifier):
  payload = { "data": { "attributes": { "primary_identifier": identifier } } }
  return self.client.post('cognito/login', data=json.dumps(payload), headers=self.iam_header )

def create_and_login_as_cognito_user(self):
  iam_login_response = login_as_iam_user(self)
  self.iam_header = { "authorization": iam_login_response.headers['Authorization'], 'content-type': 'application/vnd.api+json' }

  pool_response = create_cognito_pool(self)
  self.pool_id = json.loads(pool_response.content)['data']['id']

  identifier = Faker().pystr()
  create_cognito_user(self, identifier)

  login_response = login_cognito_user(self, identifier)
  self.cognito_header = { "authorization": login_response.headers['Authorization'], 'content-type': 'application/vnd.api+json' }
