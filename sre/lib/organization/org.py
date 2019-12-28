import json

def get_all_organization_orgs(self, header):
  self.client.get('organization/orgs', headers=header)

def get_organization_org(self, id, header):
  path = ('organization/orgs/%s' %(id))
  self.client.get(path, headers=header)

def create_organization_orgs(self, header):
  payload = { 'data': { 'type': 'orgs', 'attributes': { 'name': "MyString", 'description': "MyString", 'properties': {} } } }
  return self.client.post('organization/orgs', data=json.dumps(payload), headers=header)
