# Root main.tf 
locals {
  apps = {
    ui = {
      path                = "ui"
      port                = 80
      path_pattern        = "/*"
      ecr_repository_name = "ui"
      image_version       = "1.0.1"
      app_name            = "ui"
      is_public           = true
    }
    api = {
      path                = "api"
      port                = 8080
      path_pattern        = "/*"
      ecr_repository_name = "api"
      image_version       = "1.0.0"
      app_name            = "api"
      is_public           = false
    }
  }
}

module "infra" {
  source      = "./modules/infra"
  vpc_cidr    = "10.0.0.0/16"
  num_subnets = 2
  allowd_ips  = ["0.0.0.0/0"]
}

module "app" {
  source                 = "./modules/app"
  for_each               = local.apps
  ecr_repository_name    = each.value.ecr_repository_name
  app_path               = each.value.path
  image_version          = each.value.image_version
  app_name               = each.value.app_name
  port                   = each.value.port
  path_pattern           = each.value.path_pattern
  is_public              = each.value.is_public
  ecs_execution_role_arn = module.infra.ecs_execution_role_arn
  subnets                = module.infra.public_subnets
  security_group         = module.infra.app_security_group_id
  cluster_arn            = module.infra.cluster_arn
  vpc_id                 = module.infra.vpc_id
  alb_listener_arn       = module.infra.listener_arn

}
