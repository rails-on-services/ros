import json

def get_all_organization_orgs(self):
  self.client.get('organization/orgs', headers=self.header)

def get_organization_org(self, id):
  path = ('organization/orgs/%s' %(id))
  self.client.get(path, headers=self.header)

def create_organization_orgs(self):
  payload = { 'data': { 'type': 'orgs', 'attributes': { 'name': "MyString", 'description': "MyString", 'properties': {} } } }
  return self.client.post('organization/orgs', data=json.dumps(payload), headers=self.header)
