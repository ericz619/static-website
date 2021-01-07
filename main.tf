terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 3.0"
        }
    } 
}

variable "PRIVATE_KEY_PATH" {
    default = "my-key-pair"
}

variable "PUBLIC_KEY_PATH" {
    default = "my-key-pair.pub"
}

variable "USER_DATA_PATH" {
    default = "setup.sh"
}

variable "EC2_USER" {
  default = "ubuntu"
}

# Configure the AWS Provider
provider "aws" {}

# Create VPC
resource "aws_vpc" "main" {
    cidr_block       = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_hostnames = "true"

    tags = {
        Name = "main"
    }
}

# Create subnet 1a
resource "aws_subnet" "subnet_1_a" {
    vpc_id     = aws_vpc.main.id
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = "true"

    tags = {
        Name = "subnet_1_a"
    }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "prod-igw" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "main"
    }
}

# Create an Route Table, and associate IGW to it
resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.prod-igw.id
    }

    tags = {
        Name = "internet-rt-001"
    }
}

// # Create an assoication for our subnets
resource "aws_route_table_association" "rta" {
    subnet_id      = aws_subnet.subnet_1_a.id
    route_table_id = aws_route_table.rt.id
}

// # Create an SG for our ec2, so we can ssh into the server
resource "aws_security_group" "allow_ssh_http_sg" {
    name        = "allow_ssh_http_sg"
    description = "Allow SSH and HTTP"
    vpc_id      = aws_vpc.main.id

    # ssh
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # http
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "allow_ssh_http_sg"
    }
}

// # Create an EC2 instance
resource "aws_instance" "web_1" {
    ami = "ami-0885b1f6bd170450c" // default ubuntu 20.04 us-east-1
    instance_type = "t2.micro"
    subnet_id = aws_subnet.subnet_1_a.id
    vpc_security_group_ids = [aws_security_group.allow_ssh_http_sg.id]
    key_name = aws_key_pair.my-key-pair.id
    user_data = file(var.USER_DATA_PATH)

    connection {
        user = var.EC2_USER
        private_key = file(var.PRIVATE_KEY_PATH)
    }

    tags = {
        Name = "web_1_deployment"
    }
}

// # Sends your public key to the instance
resource "aws_key_pair" "my-key-pair" {
    key_name = "my-key-pair"
    public_key = file(var.PUBLIC_KEY_PATH)
}