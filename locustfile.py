import random
import json
import pdb
import os

from locust import HttpLocust, task, TaskSet, TaskSequence
from faker import Faker

# NOTE: Running load test in development
FILE = 'services/iam/tmp/mounted/credentials.json'

# NOTE: Running load test in live environment
# FILE = '../tmp/runtime/production/be/application/load-test/platform/credentials.json'

def config():
  return json.loads(open(FILE).read())

def authorization():
  access_key_id = config()[2]['credential']['access_key_id']
  secret_access_key = config()[2]['secret']
  return 'Basic %s:%s' %(access_key_id, secret_access_key)

def access_key_id(self):
  return self.config()[2]['credential']['access_key_id']

def secret_access_key(self):
  return self.config()[2]['secret']

def create_iam_user(self):
  payload =  { "data": { "type": "users", "attributes": { "username": Faker().name(), "time_zone": "SGT" } } }
  self.client.post('iam/users', data=json.dumps(payload), headers={"authorization": authorization(), 'content-type': 'application/vnd.api+json'})  

def create_cognito_user(self, identifier):
  payload =  { "data": { "type": "users", "attributes": { "primary_identifier": identifier } } }
  return self.client.post('cognito/users', data=json.dumps(payload), headers={"authorization": authorization(), 'content-type': 'application/vnd.api+json'} )  

def login_cognito_user(self, identifier):
  payload = { "data": { "attributes": { "primary_identifier": identifier } } }
  return self.client.post('cognito/login', data=json.dumps(payload), headers={"authorization": authorization(), 'content-type': 'application/vnd.api+json' } )

class SurveyEngagement(TaskSet):
  def on_start(self):
    create_iam_user(self)

    identifier = Faker().name()
    create_cognito_user(self, identifier)
    login_response = login_cognito_user(self, identifier)

    self.token = login_response.headers['Authorization']
    self.content_type = 'application/vnd.api+json'

    engagement_response = self.create_survey_engagement()
    self.engagement_id = json.loads(engagement_response.content)['data']['id']

    organization_response = self.create_organization_orgs()
    self.org_id = json.loads(organization_response.content)['data']['id']

    campaign_response = self.create_campaign_entity()
    self.campaign_id = json.loads(campaign_response.content)['data']['id']

    reward_response = self.create_reward_entity()
    self.reward_id = json.loads(reward_response.content)['data']['id']

    batch_response = self.create_voucher_batch()
    # self.batch_id = json.loads(batch_response.content)['data'][0]['id']

  def create_voucher_batch(self):
    payload = { "data": { "type": "batch", "attributes": { "amount": 50, "start_date": "2019-01-01", "source_id": self.reward_id, "source_type": "Perx::Reward::Entity", "code_type": "single_code", "code": "100" } } }
    return self.client.post('voucher/batch', data=json.dumps(payload), headers={ "authorization": self.token, 'content-type': self.content_type } )

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
    return self.client.post('survey/engagements', data=json.dumps(payload), headers={ "authorization": self.token, 'content-type': self.content_type } )

  def create_campaign_entity(self):
    payload = { "data": { "type": "entities", "attributes": { "engagement_type": "survey", "engagement_id": self.engagement_id, "name": "Test campaign", "status": "draft" } } }
    return self.client.post('campaign/entities', data=json.dumps(payload), headers={ "authorization": self.token, 'content-type': self.content_type } )

  def create_organization_orgs(self):
    payload = { "data": { "type": "orgs", "attributes": { "name": "Starbucks", "description": "5 dollars voucher" } } }
    return self.client.post('organization/orgs', data=json.dumps(payload), headers={ "authorization": self.token, 'content-type': self.content_type } )

  def create_reward_entity(self):
    payload = { "data": { "type": "entities", "attributes": { "image_url": "https://lorempixel.com/300/300", "name": "Starbucks Voucher", "reward_type": "Cashback", "category": "F&B", "redemption_type": "Text", "cost_of_reward": 200, "organization_id": self.org_id } } }   
    return self.client.post('reward/entities', data=json.dumps(payload), headers={ "authorization": self.token, 'content-type': self.content_type } )

  # @task(20)
  # NOTE: This endpoint is not yet restful. Uncomment after the create method on voucher/entities_controller have been refactored/removed
  # def create_voucher_entities(self):
  #   payload = { 'data': { "type": "entities", "attributes": { "batch_id": self.batch_id, "source_id": self.reward_id, "source_type": "Perx::Reward::Entity", "user_id": "1" } } }
  #   response = self.client.post('voucher/entities', data=json.dumps(payload), headers={ "authorization": self.token, 'content-type': self.content_type } )

  @task(20)
  def create_possible_outcomes(self):
    payload = { 'data': { "type": "possible_outcomes", "attributes": { "result_id": self.reward_id, "result_type": "Perx::Reward::Entity", "campaign_entity_id": self.campaign_id } } }
    self.client.post('outcome/possible_outcomes', data=json.dumps(payload), headers={ "authorization": self.token, 'content-type': self.content_type } )

  @task(20)
  def create_survey_answers(self):
    payload = { "data": { "type": "answers", "attributes": { "engagement_id": 1, "campaign_entity_id": 1, "content": { "something": "good" } } } }
    self.client.post('survey/answers', data=json.dumps(payload), headers={ "authorization": self.token, 'content-type': self.content_type } )  

class SurveyEngagementService(HttpLocust):
  task_set = SurveyEngagement
  # NOTE: Running it locally
  host = 'http://localhost:3000/'
  # NOTE: Running it on uat environment with load-test tag
  # host = 'https://api-load-test.uat.whistler.perxtech.io/'
  max_weight = 500
  min_weight = 500
