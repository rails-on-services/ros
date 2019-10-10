import json
import pdb
import rootpath
from faker import Faker

# NOTE: Running load test in development
ROOT_PATH = rootpath.detect()

# NOTE: Running load test in live environment
# FILE = '../tmp/runtime/production/be/application/load-test/platform/credentials.json'

def file():
  root = ROOT_PATH[:-4] if ROOT_PATH.endswith("/ros") else ROOT_PATH
  return ('%s/tmp/runtime/development/be/application/mounted/platform/credentials.json' %(root))

def config():
  return json.loads(open(file()).read())

def authorization():
  access_key_id = config()[8]['credential']['access_key_id']
  secret_access_key = config()[8]['secret']
  authorization_key = 'Basic %s:%s' %(access_key_id, secret_access_key)
  return authorization_key

def create_iam_user(self):
  payload =  { "data": { "type": "users", "attributes": { "username": Faker().name(), "time_zone": "SGT" } } }
  self.client.post('iam/users', data=json.dumps(payload), headers={"authorization": authorization(), 'content-type': 'application/vnd.api+json'})

def login_as_iam_user(self):
  payload = { "data": { "attributes": { "account_id": "telco", "username": "Admin", "password": "asdfjkl;" } } }
  self.client.post('iam/users/sign_in', data=json.dumps(payload), headers={"authorization": authorization(), 'content-type': 'application/vnd.api+json'})

def create_cognito_user(self, identifier):
  payload =  { "data": { "type": "users", "attributes": { "primary_identifier": identifier } } }
  return self.client.post('cognito/users', data=json.dumps(payload), headers={"authorization": authorization(), 'content-type': 'application/vnd.api+json'} )

def login_cognito_user(self, identifier):
  payload = { "data": { "attributes": { "primary_identifier": identifier } } }
  return self.client.post('cognito/login', data=json.dumps(payload), headers={"authorization": authorization(), 'content-type': 'application/vnd.api+json' } )

def create_and_login_as_cognito_user(self):
  identifier = Faker().name()
  create_cognito_user(self, identifier)

  login_response = login_cognito_user(self, identifier)
  self.header = { "authorization": login_response.headers['Authorization'], 'content-type': 'application/vnd.api+json' }
