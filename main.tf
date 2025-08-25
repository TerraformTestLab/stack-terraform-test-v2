terraform {
  required_version = "~> 1.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }
  }

  cloud {
    organization = "sujay-test-01"
    workspaces {
      tags = {
        "aws-project" = "aws-playground-v2"
      }
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}
provider "random" {}

resource "random_pet" "prefix" {
  length    = 2
  separator = "-"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "${random_pet.prefix.id}-${var.vpc_name}"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_instance" "ec2" {
  ami           = "ami-0f58b397bc5c1f2e8" # Amazon Linux 2 AMI (ap-south-1)
  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnets[0]
  tags = {
    Name = "${random_pet.prefix.id}-${var.ec2_name}"
  }
}
