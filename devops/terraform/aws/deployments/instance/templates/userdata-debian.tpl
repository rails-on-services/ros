#cloud-config
repo_update: true
repo_upgrade: all

packages:
  - git
  - gnupg2
  - software-properties-common
  - python-pip

runcmd:
  - curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
  - add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
  - pip install ansible docker-compose
  - apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io
  - "echo ${public_key_openssh} >> /home/admin/.ssh/authorized_keys"
