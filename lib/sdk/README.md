
# RosSdk


## Configuration

For local development without docker you probably want to run services on different ports:

`export PLATFORM__SERVICES__CONNECTION__TYPE=port`

For local development with docker-compse and nginx probalby want to run with paths:

`export PLATFORM__SERVICES__CONNECTION__TYPE=path`

```ruby
ENV["#{partition.upcase}_PROFILE"] || 'default')
ENV["#{partition.upcase}_ACCESS_KEY_ID"],
ENV["#{partition.upcase}_SECRET_ACCESS_KEY"])
```

`bin/console https://api.ros.rails-on-services.org 222222222_Admin_2 perx`

Ros::Sdk.configured_services
Ros::Sdk.service_endpoints
