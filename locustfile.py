import random

from locust import HttpLocust, task, TaskSet, TaskSequence
import json

FILE = 'tmp/runtime/development/be/application/mounted/platform/credentials.json'

class IamTests(TaskSet):
    def config(self):
      return json.loads(open(FILE).read())

    def access_key_id(self):
      return self.config()[2]['credential']['access_key_id']

    def secret_access_key(self):
      return self.config()[2]['secret']

    def authorization(self):
      # return "Basic %s:%s" % (self.access_key_id(), self.secret_access_key())
      # return "Bearer eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vaWFtLmxvY2FsaG9zdDozMDAwIiwic3ViIjoidXJuOndoaXN0bGVyOmlhbTo6MjIyMjIyMjIyOnVzZXIvQWRtaW5fMiIsInNjb3BlIjoiKiIsImF1ZCI6WyJodHRwOi8vbG9jYWxob3N0OjMwMDAiXSwiaWF0IjoxNTY3NTc1MTI1fQ.I7y4FLu1gk5lNTwesp52SvKD4FuzxJcYtCMKj4V6nLM"
      # return "Basic AEPEMJNUOYLNMPINPXLQ:KWfCzUehJJBfJRPcY2F6LbCugCwSVSsG1SnG0uqcpc6cLISQ7EQttg"
      return "Bearer eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2lhbS5hcGkud2hpc3RsZXIucGVyeHRlY2gub3JnIiwic3ViIjoidXJuOnBlcng6aWFtOjoyMjIyMjIyMjI6dXNlci9BZG1pbl8yIiwic2NvcGUiOiIqIiwiYXVkIjpbImh0dHBzOi8vYXBpLndoaXN0bGVyLnBlcnh0ZWNoLm9yZyJdLCJpYXQiOjE1Njc4MzY5MjB9.fyCT7D74FMNhFpuUJAn9Nxpxu3pMLBJ5bsHMw_L_bQE"

    @task(4)
    def get_iam_users(self):
        self.client.get('/iam/users', headers={"authorization": self.authorization()})

    @task(2)
    def get_cognito_users(self):
        self.client.get('/cognito/users', headers={"authorization": self.authorization()})

    @task(2)
    def cognito_login(self):
        self.client.post('/cognito/login', { "data": { "attributes": { "primary_identifier": "Mariaidentifier" } } }, headers={"authorization": self.authorization()})

  #  @task
  #  def shake(self):
  #      with self.client.put("/v4/games/2", catch_response=True) as response:
  #          if response.status_code != 200:
  #              response.failure(response.content)


class IamService(HttpLocust):
    task_set = IamTests
    # host = 'http://localhost:3000'
    host = 'https://api.whistler.perxtech.org'
    # max_weight =
    # min_weight =
