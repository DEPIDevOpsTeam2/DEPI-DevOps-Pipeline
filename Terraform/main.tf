# Define S3 bucket to store .json ,pem and tfstate files
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-json-pem-state-bucket"  
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_iam_policy" "s3_bucket_policy_permissions" {
  name        = "S3BucketPolicyPermissions"
  description = "Policy to allow PutBucketPolicy on specific S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "s3:PutBucketPolicy"
        Resource = "arn:aws:s3:::my-json-pem-state-bucket" # Replace with your bucket ARN
      },
      {
        Effect = "Allow"
        Action = "s3:GetBucketPolicy"
        Resource = "arn:aws:s3:::my-json-pem-state-bucket" # To view the current policy
      }
    ]
  })
}

resource "aws_iam_user" "example_user" {
  name = "example_user"
}

resource "aws_iam_user_policy_attachment" "example_user_policy_attachment" {
  user       = aws_iam_user.example_user.name
  policy_arn = aws_iam_policy.s3_bucket_policy_permissions.arn
}

# Store .json file, solar system db
resource "aws_s3_object" "my_json_file" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "superData.planets.json"
  source = "superData.planets.json" # Path to JSON file
}

# Store .pem file, certificate required to authenticate to db cluster
resource "aws_s3_object" "my_pem_file" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "global-bundle.pem"
  source = "global-bundle.pem" # Path to .pem file
}

# Store .tfstate file, terraform state file
resource "aws_s3_object" "my_state_file" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "terraform.tfstate"
  source = "terraform.tfstate" # Path to .tfstate file
}

# Define AWS provider
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Create a VPC
resource "aws_vpc" "solar_system_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true # Enable DNS support
  enable_dns_hostnames = true # Enable DNS hostnames
}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.solar_system_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true # To give ec2 public ip
}

# Create Private Subnet
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.solar_system_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"
}

# Create Private Subnet 2
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.solar_system_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}c"
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.solar_system_vpc.id
}

# Create Route Table for Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.solar_system_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Create Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Security Group for DocumentDB
resource "aws_security_group" "docdb_sg" {
  vpc_id = aws_vpc.solar_system_vpc.id

  ingress {
    from_port       = 27017 # MongoDB default port
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]                                                   # Allow traffic from EC2 security group
    cidr_blocks     = [aws_subnet.private_subnet_1.cidr_block, aws_subnet.private_subnet_2.cidr_block] # Allow traffic from private subnet
  }
}

resource "aws_docdb_subnet_group" "solar_system_subnet_group" {
  name       = "solar-system-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id] # Reference private subnets

  tags = {
    Name = "SolarSystemSubnetGroup"
  }
}

# Create DocumentDB Cluster
resource "aws_docdb_cluster" "solar_system_db" {
  cluster_identifier     = var.db_name
  master_username        = var.db_username
  master_password        = var.db_password
  skip_final_snapshot    = true                                                  # AWS will not create a final snapshot when the cluster is deleted - no backup data stored
  db_subnet_group_name   = aws_docdb_subnet_group.solar_system_subnet_group.name # Reference the new subnet group
  vpc_security_group_ids = [aws_security_group.docdb_sg.id]
}

# Create DocumentDB Cluster Instance
resource "aws_docdb_cluster_instance" "solar_system_db_instance" {
  count              = 1
  engine             = "docdb" # docdb 5.0.0
  cluster_identifier = aws_docdb_cluster.solar_system_db.id
  instance_class     = "db.t3.medium"
}

# Create Security Group for EC2 Instance
resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.solar_system_vpc.id

  ingress {
    from_port   = 3000 # HTTP port for your app
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80 # HTTP port for your app
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22 # SSH port
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # Allow all protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow outbound traffic to anywhere
  }
}

# Create a key pair for ec2
resource "aws_key_pair" "web_key_pair" {
  key_name   = var.key_pair_name
  public_key = var.ssh_public_key
}

# Create EC2 Instance for Solar System App
resource "aws_instance" "solar_system_app" {
  ami                    = var.aws_ec2_ami
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  # Add depends_on to ensure the DocumentDB cluster is created first
  depends_on = [aws_docdb_cluster.solar_system_db]
  key_name   = aws_key_pair.web_key_pair.key_name

  tags = {
    Name = "SolarSystemApp"
  }

  # User data script to install and start application
  user_data = <<-EOF
              #!/bin/bash
              echo "root:${var.ec2_root_password}" | chpasswd
              EOF
}
