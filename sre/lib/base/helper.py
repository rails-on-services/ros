import json
import pdb
import os

from lib.cognito import user as cognito_user
from faker import Faker

def create_and_login_as_cognito_user(self, pool_id, header):
  identifier = Faker().pystr()
  cognito_user.create_cognito_user(self, identifier, pool_id, header)
  cognito_user.login_cognito_user(self, identifier, header)
