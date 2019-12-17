# IAM

## Identity and Access Management.

As the name suggests, this service is responsible for managing the individual identities as well as their access rights.

Currently, our implementation follows a couple of assumptions that we believe would be a common pattern to the tech industry, but they are not set in stone, so any proposals for improvement or changes are more than welcome.
Service Assumptions

ROS as well as Whistler supports multi tenancy. We run on top of Postgres so we use the postgres schemas to store the all the tenant related data. In our current approach for IAM, our first approach is that every tenant has to have a root account. The root account should have permission to do any action within the tenancy data.

Based on this approach, we believe we should also have a platform owner. Similarly, this platform owner will be represented in the database, but being a special case, it has its information stored in the public schema. This helps us ensure that there should be at most one platform owner.

## Credentials Management

Each iam user as well as root user can have multiple access key credentials and use them to identify themselves with the service. These credentials are a combination of a access_key_id and a secret_access_key. The secret access key is stored encoded in the database and once we lose the reference to the unencoded secret access key it can’t be retrieved.
Authentication and subsequent authentications

When a user makes a request to any of the services in the ros architecture, we firstly identify the user within the platform. This is achieved by validating the credentials used against our registered credentials. Once it’s successfully identified, we add a claim so further requests won’t need to go to the IAM service.
Email confirmation/reset password workflow

For now, IAM user can’t sign up on his own. New user can be created by sending POST request to/iam/users with appropriate credentials. Once user is created he/she received the “welcome“ email with the link to reset password.

In order to be logged in user should confirm the email. Email can be confirmed in 2 ways:

1. By reset password link (both for existing and new users)
1. By email confirmation link (reconfirmation)

Once the user reset password we send “Authorization“ header with the response.

When existing user changing the email, IAM service returns new (unconfirmed) email in unconfirmed_email attribute.

## Users

## Credentials

## ..
