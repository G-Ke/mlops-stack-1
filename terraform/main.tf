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

resource "aws_ecr_repository" "mlops-1-ecr" {
    name = "mlops-stack-1"
}

resource "aws_ecs_cluster" "mlops-stack-1-ecs" {
    name = "mlops-stack-1"
}