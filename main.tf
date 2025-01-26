# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = false
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = false
}

provider "aws" {
  region = "us-east-2"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

# Create the VPC
resource "aws_vpc" "main" {
  cidr_block = "10.27.0.0/16"
  tags = {
    Name = "VPC-TF01"
  }
}

# Create the Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "IGW-TF01"
  }
}

# Create the Public Subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.27.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-TF-Public01"
  }
}

# Create the Private Subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.27.2.0/24"
  tags = {
    Name = "Subnet-TF-Private01"
  }
}

# Create the Manual Subnet
resource "aws_subnet" "manual" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.27.3.0/24"
  tags = {
    Name = "Subnet-Manual-Private01"
  }
}

# Create the Public Subnet Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "RouteTable-TF-Public"
  }
}

# Create the Private Subnet Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "RouteTable-TF-Private"
  }
}

# Create a Route for the Public Subnet
resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

# Associate Route Tables with Subnets
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}