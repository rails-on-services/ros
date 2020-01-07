import json
from faker import Faker

def create_iam_user(self):
  payload =  { "data": { "type": "users", "attributes": { "username": Faker().name(), "time_zone": "SGT" } } }
  self.client.post('iam/users', data=json.dumps(payload))

def login_as_iam_user(self, account_id, username, password):
  payload = { "data": { "attributes": { "account_id":  account_id, "username": username, "password": password } } }
  iam_login_response = self.client.post('iam/users/sign_in', data=json.dumps(payload), headers={'content-type': 'application/json'})
  self.iam_header = { "authorization": iam_login_response.headers['Authorization'], 'content-type': 'application/vnd.api+json' }
  return iam_login_response
