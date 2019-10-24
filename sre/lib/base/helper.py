import json
import pdb
import os
from faker import Faker

def create_iam_user(self):
  payload =  { "data": { "type": "users", "attributes": { "username": Faker().name(), "time_zone": "SGT" } } }
  self.client.post('iam/users', data=json.dumps(payload), headers={"authorization": self.token, 'content-type': 'application/vnd.api+json'})

def login_as_iam_user(self):
  payload = { "data": { "attributes": { "account_id": "telco", "username": "Admin", "password": "asdfjkl;" } } }
  return self.client.post('iam/users/sign_in', data=json.dumps(payload), headers={'content-type': 'application/json'})

def create_cognito_user(self, identifier):
  payload =  { "data": { "type": "users", "attributes": { "primary_identifier": identifier } } }
  return self.client.post('cognito/users', data=json.dumps(payload), headers={"authorization": self.token, 'content-type': 'application/vnd.api+json'} )

def login_cognito_user(self, identifier):
  payload = { "data": { "attributes": { "primary_identifier": identifier } } }
  return self.client.post('cognito/login', data=json.dumps(payload), headers={"authorization": self.token, 'content-type': 'application/vnd.api+json' } )

def create_and_login_as_cognito_user(self):
  iam_login_response = login_as_iam_user(self)
  self.token = iam_login_response.headers['Authorization']

  identifier = Faker().pystr()
  create_cognito_user(self, identifier)

  login_response = login_cognito_user(self, identifier)
  self.header = { "authorization": login_response.headers['Authorization'], 'content-type': 'application/vnd.api+json' }
