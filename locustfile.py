import random
import json
import pdb

from locust import HttpLocust, task, TaskSet, TaskSequence
from faker import Faker

FILE = 'tmp/runtime/development/be/application/mounted/platform/credentials.json'

# def config():
#   return json.loads(open(FILE).read())

# def config(self):
#   return json.loads(open(FILE).read())

# def access_key_id(self):
#   return self.config()[2]['credential']['access_key_id']

# def secret_access_key(self):
#   return self.config()[2]['secret']  

def authorization():
  # pdb.set_trace()
  return "Basic AGKQQTPKMZQYQJIMIAMM:Li3hJQOXrwtxp_ytIXM8jv2w7d_OX62CBQ4O9d-SOTSKUO3Egw6MfA"

# def create_iam_user(self):
#   payload =  { "data": { "type": "users", "attributes": { "username": Faker().name(), "time_zone": "SGT" } } }
#   self.client.post('/iam/users', data=json.dumps(payload), headers={"authorization": authorization(), 'content-type': 'application/vnd.api+json'})  

def create_cognito_user(self, identifier):
  payload =  { "data": { "type": "users", "attributes": { "primary_identifier": identifier } } }
  return self.client.post('/cognito/users', data=json.dumps(payload), headers={"authorization": authorization(), 'content-type': 'application/vnd.api+json'} )  

def login_cognito_user(self, identifier):
  payload = { "data": { "attributes": { "primary_identifier": identifier } } }
  return self.client.post('/cognito/login', data=json.dumps(payload), headers={"authorization": authorization(), 'content-type': 'application/vnd.api+json' } )

# def create_user(self):
#   payload =  { "data": { "type": "users", "attributes": { "username": "nicolas", "time_zone": "SGT" } } }
#   return self.client.post('iam/users', data=json.dumps(payload), headers={"authorization": authorization() } )

class SurveyEngagement(TaskSet):
  def setup(self):
    identifier = Faker().name()
    create_cognito_user(self, identifier)
    login_response = login_cognito_user(self, identifier)

    self.token = login_response.headers['Authorization']
    self.content_type = 'application/vnd.api+json'

  def on_start(self):  
    batch_response = self.create_voucher_batch()
    self.batch_id = json.loads(batch_response.content)['data'][0]['id']

    engagement_response = self.create_survey_engagement()
    self.engagement_id = json.loads(engagement_response.content)['data']['id']

    campaign_response = self.create_campaign_entity()
    self.campaign_id = json.loads(campaign_response.content)['data']['id']

    organization_response = self.create_organization_orgs()
    self.org_id = json.loads(organization_response.content)['data']['id']

    reward_response = self.create_reward_entity()
    self.reward_id = json.loads(reward_response.content)['data']['id']

  def create_voucher_batch(self):
    payload = { "data": { "type": "batch", "attributes": { "amount": 50, "start_date": "2019-01-01", "source_id": 1, "source_type": "reward", "code_type": "single_code", "code": "12345" } } }
    return self.client.post('/voucher/batch', data=json.dumps(payload), headers={ "authorization": self.token, 'content-type': self.content_type } )

  def create_survey_engagement(self):
    display_properties = { 'title': 'Collect stamps',
      'sub_title': 'Amazing questionnaire',
      'questions': [
        {
          'question': 'How old are you?',
          'required': True,
          'description': 'Please tell us your current age',
          'id': '1',
          'payload': {
            'type': 'long-text',
            'max-length': 3
          }
        }
      ],
      'progress_bar_color': 'primary',
      'card_background_img_url': 'https://robohash.org/card-background.png',
      'background_img_url': 'https://robohash.org/background-image.png'
    }

    payload = { "data": { "type": "engagements", "attributes": { "title": "Test engagement", "properties": {}, "display_properties": display_properties, "description": 'description text', "image_url": "www.image.com" } } }
    return self.client.post('/survey/engagements', data=json.dumps(payload), headers={ "authorization": self.token, 'content-type': self.content_type } )

  def create_campaign_entity(self):
    payload = { "data": { "type": "entities", "attributes": { "engagement_type": "survey", "engagement_id": self.engagement_id, "name": "Test campaign", "status": "draft" } } }
    return self.client.post('/campaign/entities', data=json.dumps(payload), headers={ "authorization": self.token, 'content-type': self.content_type } )

  def create_organization_orgs(self):
    payload = { "data": { "type": "orgs", "attributes": { "name": "Starbucks", "description": "5 dollars voucher" } } }
    return self.client.post('/organization/orgs', data=json.dumps(payload), headers={ "authorization": self.token, 'content-type': self.content_type } )

  def create_reward_entity(self):
    payload = { "data": { "type": "entities", "attributes": { "name": "Starbucks Voucher", "reward_type": "Text", "category": "Voucher", "redemption_type": "Text", "cost_of_reward": 200, "organization_id": self.org_id } } }   
    return self.client.post('/reward/entities', data=json.dumps(payload), headers={ "authorization": self.token, 'content-type': self.content_type } )

  @task(5)
  def create_voucher_entities(self):
    payload = { 'data': { "type": "entities", "attributes": { "batch_id": self.batch_id, "source_id": self.reward_id, "source_type": "Perx::Reward::Entity", "campaign_entity_id": 1, "user_id": "1" } } }
    self.client.post('/voucher/entities', data=json.dumps(payload), headers={ "authorization": self.token, 'content-type': self.content_type } )

  @task(5)
  def create_possible_outcomes(self):
    payload = { 'data': { "type": "possible_outcomes", "attributes": { "result_id": 1, "result_type": "Perx::Reward::Entity", "campaign_entity_id": self.campaign_id } } }
    self.client.post('/outcome/possible_outcomes', data=json.dumps(payload), headers={ "authorization": self.token, 'content-type': self.content_type } )

  @task(5)
  def create_survey_answers(self):
    payload = { "data": { "type": "answers", "attributes": { "engagement_id": self.engagement_id, "campaign_entity_id": self.campaign_id, "content": { "something": "good" } } } }
    self.client.post('/survey/answers', data=json.dumps(payload), headers={ "authorization": self.token, 'content-type': self.content_type } )  
  
  # def authorization(self):
    # return "Basic %s:%s" % (self.access_key_id(), self.secret_access_key())
    # return "Bearer eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vaWFtLmxvY2FsaG9zdDozMDAwIiwic3ViIjoidXJuOndoaXN0bGVyOmlhbTo6MjIyMjIyMjIyOnVzZXIvQWRtaW5fMiIsInNjb3BlIjoiKiIsImF1ZCI6WyJodHRwOi8vbG9jYWxob3N0OjMwMDAiXSwiaWF0IjoxNTY3NTc1MTI1fQ.I7y4FLu1gk5lNTwesp52SvKD4FuzxJcYtCMKj4V6nLM"
    # return "Basic ADHWNYMMJMNLNEFNFMJU:90SUtEj9hxiKzl6O_aX_YH6lGIRJwVkXo2y_TTp9w4LlbV_lFXhzlQ"
    # return "Bearer eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2lhbS5hcGkud2hpc3RsZXIucGVyeHRlY2gub3JnIiwic3ViIjoidXJuOnBlcng6aWFtOjoyMjIyMjIyMjI6dXNlci9BZG1pbl8yIiwic2NvcGUiOiIqIiwiYXVkIjpbImh0dHBzOi8vYXBpLndoaXN0bGVyLnBlcnh0ZWNoLm9yZyJdLCJpYXQiOjE1Njc4MzY5MjB9.fyCT7D74FMNhFpuUJAn9Nxpxu3pMLBJ5bsHMw_L_bQE"

  # @task(5)
  # def post_iam_users(self):
  #   payload =  { "data": { "type": "users", "attributes": { "username": Faker().name(), "time_zone": "SGT" } } }
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

  #  @task
  #  def shake(self):
  #      with self.client.put("/v4/games/2", catch_response=True) as response:
  #          if response.status_code != 200:
  #              response.failure(response.content)


class SurveyEngagementService(HttpLocust):
  task_set = SurveyEngagement
  host = 'http://localhost:3000'
  max_weight = 500
  min_weight = 500
