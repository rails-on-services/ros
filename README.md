
# Rails On Services

## Overview

### IAM

Link to the IAM README.md

### Cognito

### Comm

### Storage

### Callback

### Billing

## Getting Started

## Developing

### Create a development project

```bash
ros new -f my_project https://api.ros.rails-on-services.org --dev
cd my_project/ros
mkdir services/iam/spec/dummy/tmp services/cognito/spec/dummy/tmp services/comm/spec/dummy/tmp
docker-compose up -d db
ros db:reset:seed -d -r
docker-compose up -d
```

### Publish APIs to Postman

First add your postman credential key to config/env

```bash
ros apidoc:all
```

### Create a development project for Services

```bash
ros new -f my_project https://api.ros.rails-on-services.org --dev
```

### Run the services


### Create the database and seed with sample data

```bash
source config/env
ros db:reset:seed
```


## Notes

### nginx

To reload the nginx config without restarting the container

```bash
docker container exec gems_nginx_1 nginx -s reload
```
