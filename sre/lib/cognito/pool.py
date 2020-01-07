import json
from faker import Faker

def create_cognito_pool(self, header):
  pool_name = Faker().pystr()
  payload = { "data": { "type": "pools", "attributes": { "name": pool_name } } }
  pool_response = self.client.post('cognito/pools', data=json.dumps(payload), headers=header )
  return pool_response
