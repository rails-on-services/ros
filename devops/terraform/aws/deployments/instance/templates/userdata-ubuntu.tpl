#cloud-config
repo_update: true
repo_upgrade: all

packages:
  - git
  - docker.io
  - docker-compose
  - ansible
  - python-pip

runcmd:
  - "echo ${public_key_openssh} >> /home/ubuntu/.ssh/authorized_keys"
