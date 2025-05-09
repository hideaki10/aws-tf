locals {
  ecr_url   = aws_ecr_repository.this.repository_url
  ecr_token = data.aws_ecr_authorization_token.this
}
resource "aws_ecr_repository" "this" {
  name         = var.ecr_repository_name
  force_delete = true
}

resource "terraform_data" "login" {
  provisioner "local-exec" {
    command = <<EOT
      docker login ${local.ecr_url} \
      --username ${local.ecr_token.user_name} \
      --password ${local.ecr_token.password}
      EOT
  }
}

resource "terraform_data" "build" {
  depends_on = [terraform_data.login]
  provisioner "local-exec" {
    command = <<EOT
      docker build -t ${local.ecr_url} \
      ${path.module}/apps/${var.app_path}
      EOT
  }
}

resource "terraform_data" "push" {
  triggers_replace = [var.image_version]
  depends_on       = [terraform_data.login, terraform_data.build]
  provisioner "local-exec" {
    command = <<EOT
      docker image tag ${local.ecr_url} ${local.ecr_url}:${var.image_version}
      docker image tag ${local.ecr_url} ${local.ecr_url}:latest
      docker image push ${local.ecr_url}:${var.image_version}
      docker image push ${local.ecr_url}:latest
      EOT
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.app_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_execution_role_arn
  container_definitions = jsonencode([
    {
      name      = var.app_path
      image     = "${local.ecr_url}:${var.image_version}"
      essential = true
      cpu       = 256
      memory    = 512
      portMappings = [
        {
          containerPort = var.port
          hostPort      = var.port
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = "${var.app_name}-service"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.family
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.subnets
    security_groups  = [var.security_group]
    assign_public_ip = var.is_public
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.app_path
    container_port   = var.port
  }
}


resource "aws_lb_target_group" "this" {
  name        = "${var.app_name}-target-group"
  target_type = "ip"
  port        = var.port
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.alb_listener_arn
  condition {
    path_pattern {
      values = [var.path_pattern]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}


data "aws_ecr_authorization_token" "this" {}
