terraform {
    cloud {
        organization = "g-ke"
        workspaces {
            name = "mlops-stack"
        }
    }
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">=5.4.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    name               = "MLOps-Stack-VPC"
    cidr               = "10.0.0.0/22"
    azs                = ["us-east-1a", "us-east-1d"]
    private_subnets    = ["10.0.2.0/26", "10.0.2.64/26"]
    public_subnets     = ["10.0.0.0/26", "10.0.0.64/26"]
    enable_nat_gateway = false
    enable_vpn_gateway = false
    enable_dns_hostnames = true
    enable_ipv6        = false
    tags               = {
        Project = "MLOps-Stack"
    }
}