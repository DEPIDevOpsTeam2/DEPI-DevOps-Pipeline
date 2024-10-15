## CI/CD Pipeline Documentation for Solar System Application ##

# DevOps project Group-2 
- Muhammed AbdelGhafar Muhammed
- Ahmed Khaled Mohamed Gamal
- Shaimaa Mahmoud Elsaadi Seif
- Marwa Magdi Zaki Mohamed

# Date: 15/10/2024

# 1- Project Overview
This project implements an automated CI/CD pipeline to build, test, and deploy a Solar System application using MongoDB as the database. The pipeline leverages Jenkins for continuous integration, Docker for containerization, and Ansible for configuration management, and Terraform for provisioning resources to AWS.

# 2- Technologies Used
- Jenkins: Continuous integration and delivery server.
- Docker: Containerization platform for packaging applications and dependencies.
- Ansible: Configuration management tool to automate deployment.
- Terraform: Provisioning resources to AWS
- AWS: Cloud service provider for hosting the application

# 3- Pipeline Architecture
![Alt text](https://github.com/DEPIDevOpsTeam2/DEPI-DevOps-Pipeline/blob/production/pipeline%20architecture.jpg)
- Source Code Repository: GitHub repository where the application code is stored.
- Jenkins Server: Manage the CI/CD pipeline.
- Docker: Builds and runs application containers.
- Terraform: Provisioning host and database resources on AWS.
- Ansible: Manages the deployment of the application to AWS.
- AWS: Hosts the application and database.

# 4- Setup Instructions Prerequisites
- AWS account.
- Jenkins installed (local or server).
- Docker installed.
- Ansible installed.
- Git installed.

# 5- Pipeline Steps
  # Jenkins:
  
  # Terraform:
    * Resources:
      - Create VPC with the following:
          - Create public subnet for Ec2 instance.
          - Create 2 private subnets for DocumentDB cluster (2 subnets with 2 availability zones) and create subnet group contains private subnets.
          - Create Internet Gateway.
          - Create route table for public subnet.
          - Create associate route table with public subnet.
          - Create security group for DocumentDB cluster with ingress port 27017 (MongoDB default port) and referance to ec2 security group to allow traffic from it.
          - Create security group for EC2 instance with ingress ports (3000 for APP, 22 for SSH).
      - Create DocumentDB cluster (compatible with MongDB).
      - Create DocumentDB cluster instance engine version 5.0.
      - Create EC2 instance for solar system app (Ubuntu 22.04 jammy).
      - Create a key pair for ec2.
    * Outputs:
      - host_ip: ec2 public ip to be used in Ansible
      - mongo_uri: doc db cluster connection string to be used in Ansible.
      - s3_bucket_name:  s3 bucket name to be used in Ansible.
      - s3_mongo_access_key: clutser .pem file key in s3 bucket to be used in Ansible.
      - s3_mongo_db_key: .json file key in s3 bucket to be used in Ansible.
      - host_user: ec2 user name to be used in Ansible.
      - host_become_pass: ec2 user password to be used in Ansible.
  
  # Ansible:
    * EC2 Instance Configration steps:
        - Update APT package cache.
        - Ensure target directory exists.
        - Prepare Python & AWS.
            -  Ensure Python 3 is installed.
            -  Ensure pip is installed.
            -  Ensure python3-venv is installed.
            -  Create a Python virtual environment.
            -  Install pip packages in the virtual environment.
            -  Set the Python interpreter to the virtual environment.
            -  Download mongo access PEM file from S3 bucket.
            -  Download mongo data file from S3 bucket.
        - Prepare Docker
            - Check if Docker is installed.
            - Install Docker on Debian/Ubuntu.
            - Start Docker service.
            
# 6- Conclusion
This document outlines the implementation of an automated CI/CD pipeline for a Solar System application using Jenkins, Docker, Terraform and Ansible. This pipeline enables efficient and reliable deployment to AWS, ensuring that the application is always up-to-date and fully tested.
