# Root main.tf 

module "infra" {
  source      = "./modules/infra"
  vpc_cidr    = "10.0.0.0/16"
  num_subnets = 2
  allowd_ips  = ["0.0.0.0/0"]
}

module "app" {
  source                 = "./modules/app"
  ecr_repository_name    = "ui"
  app_path               = "ui"
  image_version          = "1.0.1"
  app_name               = "ui"
  port                   = 80
  ecs_execution_role_arn = module.infra.ecs_execution_role_arn
  subnets                = module.infra.public_subnets
  security_group         = module.infra.app_security_group_id
  cluster_arn            = module.infra.cluster_arn
  is_public              = true

}
