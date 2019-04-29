locals {
  ami_filter_name_map = {
    # https://wiki.debian.org/Cloud/AmazonEC2Image/Stretch
    debian = "debian-stretch-hvm-x86_64-gp2-*"
    ubuntu = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
  }

  ami_owner_map = {
    debian = "379101102735"
    ubuntu = "099720109477"
  }

  ami_ssh_user_map = {
    debian = "admin"
    ubuntu = "ubuntu"
  }
}
