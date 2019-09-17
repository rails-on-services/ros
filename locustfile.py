import random

from locust import HttpLocust, task, TaskSet, TaskSequence
import json
import pdb
from faker import Faker
fake = Faker()

FILE = 'tmp/runtime/development/be/application/mounted/platform/credentials.json'

def authorization():
  return "Basic ADHWNYMMJMNLNEFNFMJU:90SUtEj9hxiKzl6O_aX_YH6lGIRJwVkXo2y_TTp9w4LlbV_lFXhzlQ"

# def create_iam_user(self):
#   payload =  { "data": { "type": "users", "attributes": { "username": fake.name(), "time_zone": "SGT" } } }
#   self.client.post('/iam/users', data=json.dumps(payload), headers={"authorization": authorization(), 'content-type': 'application/vnd.api+json'})  

def create_cognito_user(self, identifier):
  payload =  { "data": { "type": "users", "attributes": { "primary_identifier": identifier } } }
  return self.client.post('/cognito/users', data=json.dumps(payload), headers={"authorization": authorization(), 'content-type': 'application/vnd.api+json'})  

def login_cognito_user(self, identifier):
  payload = { "data": { "attributes": { "primary_identifier": identifier } } }
  return self.client.post('/cognito/login', data=json.dumps(payload), headers={ "authorization": authorization(), 'content-type': 'application/vnd.api+json' } )

# def create_user(self):
#   payload =  { "data": { "type": "users", "attributes": { "username": "nicolas", "time_zone": "SGT" } } }
#   return self.client.post('iam/users', data=json.dumps(payload), headers={"authorization": authorization() } )

# def login(self):

class IamTests(TaskSet):
  def on_start(self):
    identifier = fake.name()
    create_cognito_user(self, identifier)
    response = login_cognito_user(self, identifier)
    self.token = response.headers['Authorization']
    self.content_type = 'application/vnd.api+json'
    # print("<<<<<<<<<<")
    # print(user_response)

  # def config(self):
  #   return json.loads(open(FILE).read())

  # def access_key_id(self):
  #   return self.config()[2]['credential']['access_key_id']

  # def secret_access_key(self):
  #   return self.config()[2]['secret']

  # def authorization(self):
  #   return "Basic ADHWNYMMJMNLNEFNFMJU:90SUtEj9hxiKzl6O_aX_YH6lGIRJwVkXo2y_TTp9w4LlbV_lFXhzlQ"

  # def authorization(self):
    # return "Basic %s:%s" % (self.access_key_id(), self.secret_access_key())
    # return "Bearer eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vaWFtLmxvY2FsaG9zdDozMDAwIiwic3ViIjoidXJuOndoaXN0bGVyOmlhbTo6MjIyMjIyMjIyOnVzZXIvQWRtaW5fMiIsInNjb3BlIjoiKiIsImF1ZCI6WyJodHRwOi8vbG9jYWxob3N0OjMwMDAiXSwiaWF0IjoxNTY3NTc1MTI1fQ.I7y4FLu1gk5lNTwesp52SvKD4FuzxJcYtCMKj4V6nLM"
    # return "Basic ADHWNYMMJMNLNEFNFMJU:90SUtEj9hxiKzl6O_aX_YH6lGIRJwVkXo2y_TTp9w4LlbV_lFXhzlQ"
    # return "Bearer eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2lhbS5hcGkud2hpc3RsZXIucGVyeHRlY2gub3JnIiwic3ViIjoidXJuOnBlcng6aWFtOjoyMjIyMjIyMjI6dXNlci9BZG1pbl8yIiwic2NvcGUiOiIqIiwiYXVkIjpbImh0dHBzOi8vYXBpLndoaXN0bGVyLnBlcnh0ZWNoLm9yZyJdLCJpYXQiOjE1Njc4MzY5MjB9.fyCT7D74FMNhFpuUJAn9Nxpxu3pMLBJ5bsHMw_L_bQE"

  # @task(5)
  # def post_iam_users(self):
  #   payload =  { "data": { "type": "users", "attributes": { "username": fake.name(), "time_zone": "SGT" } } }
  #   self.client.post('/iam/users', data=json.dumps(payload), headers={"authorization": self.token, 'content-type': 'application/vnd.api+json'})

  # @task(2)
  # def get_iam_users(self):
  #   self.client.get('/iam/users', headers={"authorization": self.authorization()})

  # @task(2)
  # def get_cognito_users(self):
  #   self.client.get('/cognito/users', headers={"authorization": self.authorization()})

  # @task(2)
  # def cognito_login(self):
  #   payload = { "data": { "attributes": { "primary_identifier": "miller" } } }
  #   self.client.post('/cognito/login', data=json.dumps(payload), headers={ "authorization": self.authorization(), 'content-type': 'application/vnd.api+json' } )

  @task(2)
  def create_possible_outcomes(self):
    payload = { 'data': { "type": "possible_outcomes", "attributes": { "result_id": 1, "result_type": "Perx::Reward::Entity", "campaign_entity_id": 1 } } }
    self.client.post('/outcome/possible_outcomes', data=json.dumps(payload), headers={ "authorization": self.token, 'content-type': self.content_type } )

  #  @task
  #  def shake(self):
  #      with self.client.put("/v4/games/2", catch_response=True) as response:
  #          if response.status_code != 200:
  #              response.failure(response.content)


class IamService(HttpLocust):
  task_set = IamTests
  host = 'http://localhost:3000'
  # 
  # host = 'https://api.whistler.perxtech.org'
  # max_weight =
  # min_weight =
