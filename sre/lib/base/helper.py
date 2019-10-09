import json
import pdb
import rootpath
from faker import Faker

# NOTE: Running load test in development
ROOT_PATH = rootpath.detect()
FILE = ('%s/tmp/runtime/development/be/application/mounted/platform/credentials.json' %(ROOT_PATH))

# NOTE: Running load test in live environment
# FILE = '../tmp/runtime/production/be/application/load-test/platform/credentials.json'

def config():
  return json.loads(open(FILE).read())

def authorization():
  access_key_id = config()[2]['credential']['access_key_id']
  secret_access_key = config()[2]['secret']
  # return 'Basic %s:%s' %(access_key_id, secret_access_key)
  return 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2lhbS5hcGkud2hpc3RsZXIucGVyeHRlY2gubmV0Iiwic3ViIjoidXJuOnBlcng6aWFtOjo0NDQ0NDQ0NDQ6dXNlci9BZG1pbiIsImF1ZCI6WyJodHRwczovL2FwaS53aGlzdGxlci5wZXJ4dGVjaC5uZXQiXSwiaWF0IjoxNTcwNjA3NTMzfQ.jSILb36czn0HODR0ePU38-wu56ZmPL--TEP3gtNTrT0'

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
