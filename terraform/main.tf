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

resource "aws_ecr_repository" "mlops-ecr" {
    name = "MLOps-Stack-2"
}

resource "aws_ecs_cluster" "mlops-stack-2-ecs" {
    name = "MLOps-Stack-2"
}

resource "aws_ecs_task_definition" "mlops-stack-2-taskdef" {
    family                   = "MLOps-Stack-2"
    container_definitions    = <<DEFINITION
    [
        {
            "name": "MLOps-Stack-2-TaskDef",
            "image": "${aws_ecr_repository.mlops-ecr.repository_url}",
            "essential": true,
            "portMappings": [
                {
                    "containerPort": 80,
                    "hostPort": 80
                }
            ],
            "memory": 512,
            "cpu": 256,
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
    memory                   = "512"
    execution_role_arn       = "arn:aws:iam::343725977869:role/ecsTaskExecutionRole"
    task_role_arn            = "arn:aws:iam::343725977869:role/ecsTaskExecutionRole"
}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    name               = "MLOps-Stack-2-vpc"
    cidr               = "10.0.0.0/22"
    azs                = ["us-east-1a", "us-east-1d"]
    private_subnets    = ["10.0.8.0/22", "10.0.10.0/22"]
    public_subnets     = ["10.0.0.0/22", "10.0.1.0/22"]
    enable_nat_gateway = true
    enable_vpn_gateway = false
    enable_ipv6        = false
    tags               = {Project = "MLOps-Stack-2"}
}

resource "aws_alb" "mlops-alb" {
    name = "MLOps-Stack-2-alb"
    load_balancer_type = "application"
    subnets = module.vpc.public_subnets
    security_groups = [aws_security_group.mlops-stack-2-alb-sg.id]
}

resource "aws_security_group" "mlops-stack-2-alb-sg" {
    name = "MLOps-Stack-2-alb-sg"
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
}

resource "aws_lb_target_group" "mlops-stack-2-tg" {
    name = "MLOps-Stack-2-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = module.vpc.vpc_id
    target_type = "ip"
    health_check {
        path = "/"
        port = "traffic-port"
        protocol = "HTTP"
        matcher = "200-399"
        interval = 30
        timeout = 5
    }
}

resource "aws_lb_target_group_attachment" "mlops-stack-2-tg-attachment" {
    target_group_arn = aws_lb_target_group.mlops-stack-2-tg.arn
    target_id = aws_alb.mlops-alb.arn
    port = 80
}

resource "aws_lb_listener" "mlops-stack-2-listener" {
    load_balancer_arn = aws_alb.mlops-alb.arn
    port = 80
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.mlops-stack-2-tg.arn
    }
}

resource "aws_ecs_service" "mlops-stack-2-service" {
    name = "MLOps-Stack-2-service"
    cluster = aws_ecs_cluster.mlops-stack-2-ecs.id
    task_definition = aws_ecs_task_definition.mlops-stack-2-taskdef.family
    launch_type = "FARGATE"
    desired_count = 1

    load_balancer {
        target_group_arn = aws_lb_target_group.mlops-stack-2-tg.arn
        container_name = aws_ecs_task_definition.mlops-stack-2-taskdef.family
        container_port = 80
    }

    network_configuration {
        subnets = module.vpc.public_subnets
        security_groups = [aws_security_group.mlops-stack-2-sg.id]
        assign_public_ip = true
    }
}

resource "aws_security_group" "mlops-stack-2-sg" {
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        security_groups = [aws_security_group.mlops-stack-2-alb-sg.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "mlops-stack-2-url" {
    value = aws_alb.mlops-alb.dns_name
}