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

resource "aws_default_network_acl" "default" {
    default_network_acl_id = "acl-01be051a12f755913"

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

resource "aws_ecs_cluster" "mlops-stack-ecs" {
    name = "MLOps-Stack"
}

resource "aws_ecs_cluster_capacity_providers" "mlops-stack-ecs-cp" {
    cluster_name = aws_ecs_cluster.mlops-stack-ecs.name
    capacity_providers = ["FARGATE"]
    default_capacity_provider_strategy {
        base              = 1
        weight            = 100
        capacity_provider = "FARGATE"
    }
}

resource "aws_ecs_task_definition" "mlops-stack-taskdef" {
    family                   = "MLOps-Stack"
    container_definitions    = <<DEFINITION
    [
        {
            "name": "MLOps-Stack",
            "image": "343725977869.dkr.ecr.us-east-1.amazonaws.com/mlops-stack-1",
            "essential": true,
            "portMappings": [
                {
                    "containerPort": 80,
                    "hostPort": 80
                }
            ],
            "command": [
                "uvicorn",
                "main:app",
                "--host=0.0.0.0",
                "--port=80"
            ]
        }
    ]
    DEFINITION
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    cpu                      = "256"
    memory                   = "2048"
    execution_role_arn       = "arn:aws:iam::343725977869:role/ecsTaskExecutionRole"
    task_role_arn            = "arn:aws:iam::343725977869:role/ecsTaskExecutionRole"
}

resource "aws_ecs_service" "mlops-stack-ecs-service" {
    name = "MLOps-Stack-Service"
    cluster = aws_ecs_cluster.mlops-stack-ecs.id
    task_definition = aws_ecs_task_definition.mlops-stack-taskdef.arn
    desired_count = 1
    launch_type = "FARGATE"
    capacity_provider_strategy {
        capacity_provider = aws_ecs_cluster_capacity_providers.MLOps-Stack-ecs-cp.arn
        weight = 100
    }
    load_balancer {
        target_group_arn = aws_lb_target_group.mlops-stack-alb-tg.arn
        container_name   = "MLOps-Stack"
        container_port   = 80
    }
    network_configuration {
        assign_public_ip = true
        subnets = module.vpc.public_subnets
        security_groups = [aws_security_group.mlops-stack-VPC-sg.id]
    }
}

resource "aws_lb" "mlops-stack-alb" {
    name = "MLOps-Stack-ALB"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.mlops-stack-VPC-sg.id]
    subnets = module.vpc.public_subnets
}

resource "aws_lb_listener" "mlops-stack-alb-listener" {
    load_balancer_arn = aws_lb.mlops-stack-alb.arn
    port = "80"
    protocol = "HTTP"
    default_action {
        type = "forward"
        forward {
            target_group {
                arn = aws_lb_target_group.mlops-stack-alb-tg.arn
                weight = 100
            }
        }
    }
}

resource "aws_lb_target_group" "mlops-stack-alb-tg" {
    name = "MLOps-Stack-ALB-TG"
    target_type = "alb"
    port = 80
    protocol = "TCP"
    vpc_id = module.vpc.vpc_id
}

resource "aws_lb_target_group_attachment" "mlops-stack-lb-tga" {
    target_group_arn = aws_lb.mlops-stack-alb.arn
    target_id = aws_lb.mlops-stack-alb.dns_name
    port = 80
}