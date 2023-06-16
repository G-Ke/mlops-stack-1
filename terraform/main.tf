terraform {
    cloud {
        organization = "g-ke"
        workspaces {
            name = "mlops-stack-1"
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

module "ec2_instance" {
    source  = "terraform-aws-modules/ec2-instance/aws"

    name = "single-instance"

    instance_type          = "t2.micro"
    key_name               = "MyEC2KP"
    monitoring             = false
    vpc_security_group_ids = ["sg-0aae88811984b6ba2"]

    tags = {
    Terraform   = "true"
    Environment = "dev"
    }
}