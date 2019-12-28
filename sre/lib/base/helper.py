import json
import pdb
import os
from faker import Faker

def create_iam_user(self):
  payload =  { "data": { "type": "users", "attributes": { "username": Faker().name(), "time_zone": "SGT" } } }
  self.client.post('iam/users', data=json.dumps(payload))

def login_as_iam_user(self):
  payload = { "data": { "attributes": { "account_id": "generic", "username": "Admin", "password": "asdfjkl;" } } }
  iam_login_response = self.client.post('iam/users/sign_in', data=json.dumps(payload), headers={'content-type': 'application/json'})
  self.iam_header = { "authorization": iam_login_response.headers['Authorization'], 'content-type': 'application/vnd.api+json' }
  return iam_login_response

def create_cognito_pool(self, header):
  pool_name = Faker().pystr()
  payload = { "data": { "type": "pools", "attributes": { "name": pool_name } } }
  pool_response = self.client.post('cognito/pools', data=json.dumps(payload), headers=header )
  return pool_response

def create_anonymous_user(self, identifier, header):
  payload = { "data": { "type": "users", "attributes": { "primary_identifier": identifier, 'anonymous': True } } }
  return self.client.post('cognito/users', data=json.dumps(payload), headers=header )

def login_anonymous_user(self, identifier, header):
  payload = { "data": { "type": "login", "attributes": { "primary_identifier": identifier } } }
  login_response = self.client.post('cognito/login', data=json.dumps(payload), headers=header )
  self.anonymous_header = { "authorization": login_response.headers['Authorization'], 'content-type': 'application/vnd.api+json' }

def create_cognito_user(self, identifier, pool_id, header):
  payload =  { "data": { "type": "users", "attributes": { "primary_identifier": identifier }, "relationships": { "pools": { "data": [{ "type": "pools", "id": pool_id }] } } } }
  return self.client.post('cognito/users', data=json.dumps(payload), headers=header )

def login_cognito_user(self, identifier, header):
  payload = { "data": { "attributes": { "primary_identifier": identifier } } }
  login_response = self.client.post('cognito/login', data=json.dumps(payload), headers=header )
  self.cognito_header = { "authorization": login_response.headers['Authorization'], 'content-type': 'application/vnd.api+json' }

def cognito_chown_request(self, anonymous_ids, cognito_id, header):
  payload = { "data": { "type": "chown_requests", "attributes": { "from_ids": anonymous_ids, "to_id": cognito_id } } }
  self.client.post('cognito/chown_requests', data=json.dumps(payload), headers=header)

def create_and_login_as_cognito_user(self, pool_id, header):
  identifier = Faker().pystr()
  create_cognito_user(self, identifier, pool_id, header)
  login_cognito_user(self, identifier, header)
