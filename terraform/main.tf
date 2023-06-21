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

resource "aws_security_group" "mlops-stack-VPC-sg" {
    name = "MLOps-Stack-VPC-sg"
    vpc_id = module.vpc.vpc_id
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Project = "MLOps-Stack"
    }
}

resource "aws_network_acl" "mlops-stack-VPC-nacl" {
    vpc_id = module.vpc.vpc_id

    ingress {
        protocol   = "tcp"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 80
        to_port    = 80
    }

    ingress {
        protocol   = "tcp"
        rule_no    = 200
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 443
        to_port    = 443
    }

    ingress {
        protocol   = "tcp"
        rule_no    = 300
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 53
        to_port    = 53
    }

    ingress {
        protocol   = "udp"
        rule_no    = 400
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 53
        to_port    = 53
    }    

    ingress {
        protocol   = "tcp"
        rule_no    = 500
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 42
        to_port    = 42
    } 

    egress {
        protocol   = "-1"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = "0"
        to_port    = "0"
    }

    tags = {
        Project = "MLOps-Stack"
    }
}

resource "aws_default_network_acl" "default" {
    vpc_id = module.vpc.vpc_id

    ingress {
        protocol   = "tcp"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 80
        to_port    = 80
    }

    ingress {
        protocol   = "tcp"
        rule_no    = 200
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 443
        to_port    = 443
    }

    ingress {
        protocol   = "tcp"
        rule_no    = 300
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 53
        to_port    = 53
    }

    ingress {
        protocol   = "udp"
        rule_no    = 400
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 53
        to_port    = 53
    }    

    ingress {
        protocol   = "tcp"
        rule_no    = 500
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 42
        to_port    = 42
    } 

    egress {
        protocol   = "-1"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = "0"
        to_port    = "0"
    }

    tags = {
        Project = "MLOps-Stack"
    }
}