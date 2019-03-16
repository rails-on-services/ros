
# IAM

User Rob belongs to group Administrators
Group Administrators has Role FullAccess

User Pearl belongs to group DashboardUser
Group DashboardUser has Role DashboardFullAccess

Post is a model
PostPolicy.update? current_user.has_role?

## Groups

Groups have 0 or more attached Policies which give permission for specific actions
Groups have 0 or more Users

## Users

User have 0 or more attached Policies which give permission for specific actions
Users belong to 0 or more Groups
Users inherit Group permissions

## Roles

Roles have many policies
A User may have permission to assume a specific Role
The Role is assumed in order to accomplish a specific Action for which that specific Role has Permission


## Policies

Policies permit or deny certain Actions

Example:

AlexaForBusinessDeviceSetup

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "a4b:RegisterDevice",
                "a4b:CompleteRegistration",
                "a4b:SearchDevices"
            ],
            "Resource": "*"
        }
    ]
}
```
