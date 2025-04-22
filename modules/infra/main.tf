locals {
  azs = data.aws_availability_zones.avaliability.names
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "terraform-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  tags = {
    Name = "terraform-igw"
  }
}

resource "aws_internet_gateway_attachment" "this" {
  internet_gateway_id = aws_internet_gateway.this.id
  vpc_id              = aws_vpc.this.id
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "terraform-route-table"
  }
}

resource "aws_route" "this" {
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_subnet" "this" {
  #for_each   = toset(var.subnet_cidrs)
  for_each = { for i in range(var.num_subnets) : "public${i}" => i }
  vpc_id   = aws_vpc.this.id
  #cidr_block = "10.0.${each.value}.0/24"
  cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 8, each.value)
  # 均等に分散
  availability_zone = local.azs[each.value % length(local.azs)]
  tags = {
    Name = "terraform-subnet-${each.key}"
  }
}

resource "aws_route_table_association" "this" {
  for_each       = aws_subnet.this
  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.this.id
}

resource "aws_lb" "this" {
  name               = "terraform-ecs-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for subnet in aws_subnet.this : subnet.id]
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "I'm working,but the tasks aren't "
      status_code  = "503"
    }
  }
}

resource "aws_security_group" "alb" {
  description = "terraform security group for alb"
  vpc_id      = aws_vpc.this.id
  tags = {
    Name = "terraform-security-group"
  }
}

# secruity group ingress rule internet -> alb
resource "aws_vpc_security_group_ingress_rule" "alb" {
  for_each          = var.allowd_ips
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = each.value
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_ecs_cluster" "this" {
  name = "terraform-ecs-cluster"
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecsExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# app secruity group
resource "aws_security_group" "app" {
  description = "terraform security group for app"
  vpc_id      = aws_vpc.this.id
  tags = {
    Name = "terraform-security-group-app"
  }
}

# egress rule alb -> app 
resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol                  = "-1"
  tags = {
    Name = "terraform-security-group-alb-to-app"
  }
}

# ingree rule alb -> app
resource "aws_vpc_security_group_ingress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "-1"
  tags = {
    Name = "terraform-security-group-app-to-alb"
  }
}

# egress rule app -> internet
resource "aws_vpc_security_group_egress_rule" "app_to_internet" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  tags = {
    Name = "terraform-security-group-app-to-internet"
  }
}



data "aws_availability_zones" "avaliability" {
  state = "available"
}
