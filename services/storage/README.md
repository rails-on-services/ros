# Storage

Storage service for Cloud Native Full Stack

Handles file uploads and downloads by SFTP and API

SFTP server mounts cloud storage, eg S3 bucket on AWS

File uploads trigger a message to eg SQS

This storage service receives the event and processes the file

Depending on the file fingerprint, the storage service notifies the relevant service of a new file


## Development

Ensure the SFTP server, IAM, Congito, Comm and Storage services are running

sftp -P 2222 222222222@localhost

### Pre-requisites

IAM Service creates tenant locations on cloud storage




## Installation
Add this line to your application's Gemfile:

```ruby
gem 'ros-storage'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install storage
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

# Documentation
[Rails on Services Guides](https://guides.rails-on-services.org)
