# Terraform module for rails-on-services

Terraform module which creates resources (helm releases) inside a kubernetes cluster.

## Resources

Following resources are part of the module:

* iam helm release
* comm helm release
* cognito helm release
* [OPTIONAL] istio Gateway and VirtualService to expose the services to outside
