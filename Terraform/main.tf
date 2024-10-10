#Define AWS proviser
provider "aws" {
  region = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Create a VPC
resource "aws_vpc" "solar_system_vpc" { 
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true  # Enable DNS support
  enable_dns_hostnames = true # Enable DNS hostnames
}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.solar_system_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true # To give ec2 public ip
}

# Create Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.solar_system_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
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

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Security Group for DocumentDB
resource "aws_security_group" "docdb_sg" {
  vpc_id = aws_vpc.solar_system_vpc.id

  ingress {
    from_port   = 27017 # MongoDB default port
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_subnet.cidr_block]  # Allow traffic from private subnet
  }
}

# Create DocumentDB Cluster
resource "aws_docdb_cluster" "solar_system_db" {
  cluster_identifier = "solar-system-db"
  master_username   = var.db_username
  master_password   = var.db_password
  skip_final_snapshot = true # AWS will not create a final snapshot when the cluster is deleted - no backup data stored
  # vpc_security_group_ids  = [aws_security_group.app_sg.id]
}

# Create DocumentDB Cluster Instance
resource "aws_docdb_cluster_instance" "solar_system_db_instance" {
  engine            = "docdb"
  count              = 2  # 2 instance for redundancy - optional
  cluster_identifier = aws_docdb_cluster.solar_system_db.id
  instance_class     = "db.r5.large" 
}

# Create Security Group for EC2 Instance
resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.solar_system_vpc.id

  ingress {
    from_port   = 80  # HTTP port for your app
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 27017  # MongoDB port for db
    to_port     = 27017
    protocol    = "tcp"
    security_groups = [aws_security_group.docdb_sg.id]  # Allow access from DocumentDB
  }

  ingress {
    from_port   = 22  # SSH port
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
}
             
# Create EC2 Instance for Solar System App
resource "aws_instance" "solar_system_app" {
  ami           = "ami-005fc0f236362e99f"  # Replace with your AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids  = [aws_security_group.app_sg.id]

  tags = {
    Name = "SolarSystemApp"
  }

  # User data script to install and start your application
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              # Add commands to install and run your application
              EOF
}

output "instance_public_ip" {
  value = aws_instance.solar_system_app.public_ip
}

output "db_endpoint" {
  value = aws_docdb_cluster.solar_system_db.endpoint  # To Connect app to the DocumentDB instance by using the endpoint in connection string
}
