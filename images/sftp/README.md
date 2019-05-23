# SFTP Container with S3 Mount

### Configure the server with host keys

The SFTP server runs SSH. It needs keys for the client to identify the ssh connection:

```bash
ssh-keygen -N '' -t ed25519 -f sshx/ssh_host_ed25519_key > /dev/null
ssh-keygen -N '' -t rsa -b 4096 -f sshx/ssh_host_rsa_key > /dev/null
```

## Quickstart with Localstack

Localstack provides a local S3 service so you don't need an actual S3 bucket on AWS

### Start the service

```bash
docker-compose up
```

The SFTP service is now running on your localhost on port 2222.

### Connect to the service

```bash
sftp -P 2222 foo@localhost
```

The password is `pass`

### Use the service

After logging in you can list files:

```bash
ls
```

Upload a file:

```bash
put README.md uploads
```

And logout:

```bash
exit
```

### Connect to the SFTP service with your SSH key

To connect with your ssh key as the user `foo` write your public key to the server's authorized-keys directory

```bash
cp ~/.ssh/id_rsa.pub sshx/authorized-keys/foo
```

Now download the README.md that you uploaded previously:

```bash
sftp -P 2222 foo@localhost:uploads/README.md
```

## Quickstart with AWS

### Create AWS credentials for SFTP server to use

Replace the AWS credentials in docker-compose.yml with valid credentials and comment out the `BUCKET_ENDPOINT_URL` value

### Run the servcie

```bash
docker-compose down
docker-compose up
```

### Use the service

[Just as above](#Use the service)


## Notes

### Localstack

By default localstack will output TCP/IP communications between the SFTP container and localstack
To turn off the output, comment out the `DEBUG: S3` line in docker-compose.yml

### Default SFTP users

The file users.conf contains three test users with passwords. The users are `foo`, `bar` and `baz`.
Their passwords are `pass`. All users have two directories they can write to: `uploads` and `downloads`
