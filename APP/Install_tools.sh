#!/bin/bash
#add Environment varibles
export S3_MONGO_ACCESS_KEY=$(terraform output -raw  s3_mongo_access_key)
export S3_MONGO_DB_KEY=$(terraform output -raw s3_mongo_db_key)
export S3_BUCKET_NAME=$(terraform output -raw s3_bucket_name)
export MONGO_URI=$(terraform output -raw mongo_uri)
export HOST_IP=$(terraform output -raw host_ip)
export HOST_USER=$(terraform output -raw host_user)
export HOST_BECOME_PASS=$(terraform output -raw host_become_pass)
export APP_NAME="solar-app"
export APP_IMG="m2a2/solar-system:a5fb10e8ce9f6e433d1ff0e4da058c162d69abd8"
export MONGO_DB="superData"
export MONGO_COLLECTION="planets"
export AWS_ACCESS_KEY_ID="AKIA4HWJUL3TXDCM54KR"
export AWS_SECRET_ACCESS_KEY="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"
export AWS_REGION="us-east-2"
export HOST_SSH_PRV_KEY="~/.ssh/id_aws_ec2"

# install Terraform
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform

#install Ansible
UBUNTU_CODENAME=jammy
wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | sudo gpg --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/ansible.list
sudo apt update && sudo apt install ansible

#install Docker
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
