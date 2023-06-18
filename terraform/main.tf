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

resource "aws_ecs_task_definition" "mlops-1-task" {
    family = "mlops-1-task"
    container_definitions = <<DEFINITION
    [
        {
            "name": "mlops-1-task",
            "image": "${aws_ecr_repository.mlops-1-ecr.repository_url}",
            "essential": true,
            "portMappings": [
                {
                    "containerPort": 8000,
                    "hostPort": 8000
                }
            ],
            "memory": 512,
            "cpu": 256
        }
    ]
    DEFINITION
    requires_compatibilities = ["FARGATE"]
    network_mode = "awsvpc"
    memory = 512
    cpu = 256
    execution_role_arn = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
    name = "ecsTaskExecutionRole-MLOps"
    assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

data "aws_iam_policy_document" "assume_role_policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRolePolicy" {
    role = "${aws_iam_role.ecsTaskExecutionRole.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_default_vpc" "default_vpc" {
}

resource "aws_default_subnet" "default_subnet_a" {
    availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
    availability_zone = "us-east-1b"
}

resource "aws_alb" "application_load_balancer" {
    name = "mlops-load-balancer"
    load_balancer_type = "application"
    subnets = [
        "${aws_default_subnet.default_subnet_a.id}",
        "${aws_default_subnet.default_subnet_b.id}"
    ]
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

resource "aws_security_group" "load_balancer_security_group" {
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

resource "aws_lb_target_group" "target_group" {
    name = "mlops-target-group"
    port = 80
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = "${aws_default_vpc.default_vpc.id}"
}

resource "aws_lb_listener" "listener" {
    load_balancer_arn = "${aws_alb.application_load_balancer.arn}"
    port = "80"
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = "${aws_lb_target_group.target_group.arn}"
    }
}

resource "aws_ecs_service" "mlops-1-service" {
    name = "mlops-1-service"
    cluster = "${aws_ecs_cluster.mlops-stack-1-ecs.id}"
    task_definition = "${aws_ecs_task_definition.mlops-1-task.family}"
    launch_type = "FARGATE"
    desired_count = 3

    load_balancer {
        target_group_arn = "${aws_lb_target_group.target_group.arn}"
        container_name = "${aws_ecs_task_definition.mlops-1-task.family}"
        container_port = 8000
    }

    network_configuration {
        subnets = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}"]
        assign_public_ip = true
        security_groups = ["${aws_security_group.ecs_service_security_group.id}"]
    }
}

resource "aws_security_group" "ecs_service_security_group" {
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "mlops-stack-url" {
    value = aws_alb.application_load_balancer.dns_name
}