## Summary

Created by rails-templates


def tcall(from: '+12565308753', to: '+6581132988')
  @twilio_client.calls.create(to: to, from: from, url: 'http://demo.twilio.com/docs/voice.xml')
end

def tsms(from: '+12565308753', to: '+6581132988', body: 'Hey friend!')
  @twilio_client.messages.create(
    from: from,
    to: to,
    body: body
  )
end

