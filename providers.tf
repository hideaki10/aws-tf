terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "dev-user-terraform"
  default_tags {
    tags = {
      App = "terraform-mtc-app-demo"
      Env = "dev"
    }
  }
}
