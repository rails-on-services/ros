
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

### Run the services

```bash
docker-compose up
```

### Create the database and seed with sample data

```bash
source app.env
./init
```

### Make a postman request

```bash
cat ros/ros-iam/tmp/ros/postman/222_222_222-Admin_2.json
```

Import the output of the above command into Postman
Set a global variable `host` to the server name or IP running the service, e.g. `localhost:3000`

Set headers:
`Authorization` to `Basic {{ros_access_key_id}}:{{ros_secret_access_key}}`
`Content-Type` to `application/vnd.api+json`

Create and endpoint by making a POST to `{{host}}/cognito/endpoints` with the following `raw` payload:

```json
{ 
  "data": {
    "type": "endpoints",
    "attributes": {
      "url": "https://surveys.example.com/hello",
      "target_id": 1,
      "target_type": "Survey::Group"
    }
  }
}
```

Retrieve the endpoint by making a GET to `{{host}}/cognito/endpoints?filter[url]=https://surveys.example.com/hello`

```
{
    "data": [
        {
            "id": "22",
            "type": "endpoints",
            "links": {
                "target": "http://13.229.71.66:3000/cognito/group/1",
                "self": "http://13.229.71.66:3000/endpoints/22"
            },
            "attributes": {
                "urn": "urn:ros:cognito::222222222:endpoint/22",
                "url": "https://surveys.example.com/hello",
                "properties": null,
                "target_type": "Cognito::Group",
                "target_id": 1
            }
        }
    ]
}

The target URL is found at data[0]['links']['target']
```


## Notes

### nginx

To reload the nginx config without restarting the container

```bash
docker container exec gems_nginx_1 nginx -s reload
```
