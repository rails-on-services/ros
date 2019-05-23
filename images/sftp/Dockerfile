FROM atmoz/sftp

ARG os_base_packages='linux-image-4.9.0-8-amd64 kmod s3fs'

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
 && apt-get upgrade --yes \
 && apt-get install --yes --no-install-recommends ${os_base_packages} \
 && apt-get clean

# NOTE: do not use --no-install-recommends to apt-get install python-pip
RUN DEBIAN_FRONTEND=noninteractive apt-get install python-pip --yes \
 && pip install awscli \
 && apt-get clean

ARG os_packages='tree less vim'

RUN DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends ${os_packages} \
 && apt-get clean \
 && echo 'set editing-mode vi' > /root/.inputrc

ENV MOUNT_DIR=/home
COPY entrypoint entrypoint
COPY sshd_config /etc/ssh/sshd_config
