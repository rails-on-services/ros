import json

def create_cognito_chown_request(self, anonymous_ids, cognito_id, header):
  payload = { "data": { "type": "chown_requests", "attributes": { "from_ids": anonymous_ids, "to_id": cognito_id } } }
  self.client.post('cognito/chown_requests', data=json.dumps(payload), headers=header)
