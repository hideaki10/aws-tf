output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "app_security_group_id" {
  value = aws_security_group.app.id
}

output "public_subnets" {
  value = [for i in aws_subnet.this : i.id]
}

output "cluster_arn" {
  value = aws_ecs_cluster.this.arn
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "listener_arn" {
  value = aws_lb_listener.this.arn
}

# output "subnet" {
#   value = aws_subnet.this
# }
