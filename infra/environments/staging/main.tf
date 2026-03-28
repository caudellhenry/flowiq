terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure once S3 bucket and DynamoDB table exist:
  # backend "s3" {
  #   bucket         = "flowiq-terraform-state"
  #   key            = "staging/terraform.tfstate"
  #   region         = "ap-southeast-2"
  #   dynamodb_table = "flowiq-terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  env = "staging"

  common_tags = {
    Project     = "flowiq"
    Environment = local.env
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  env                  = local.env
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

module "ecr" {
  source = "../../modules/ecr"

  env      = local.env
  services = ["api", "web", "ai-service"]
  tags     = local.common_tags
}

module "s3" {
  source = "../../modules/s3"

  env  = local.env
  tags = local.common_tags
}

module "iam" {
  source = "../../modules/iam"

  env                  = local.env
  documents_bucket_arn = module.s3.documents_bucket_arn
  ecr_repository_arns  = module.ecr.repository_arns
  tags                 = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  env                        = local.env
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  allowed_security_group_ids = [module.ecs.ecs_tasks_security_group_id]
  instance_class             = var.rds_instance_class
  db_name                    = var.db_name
  db_username                = var.db_username
  db_password                = var.db_password
  tags                       = local.common_tags
}

module "redis" {
  source = "../../modules/redis"

  env                        = local.env
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  allowed_security_group_ids = [module.ecs.ecs_tasks_security_group_id]
  node_type                  = var.redis_node_type
  tags                       = local.common_tags
}

module "ecs" {
  source = "../../modules/ecs"

  env               = local.env
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  certificate_arn   = var.acm_certificate_arn

  api_task_role_arn        = module.iam.api_task_role_arn
  web_task_role_arn        = module.iam.web_task_role_arn
  ai_service_task_role_arn = module.iam.ai_service_task_role_arn

  # Placeholder images — replaced by CI/CD on first deploy
  api_image        = "${module.ecr.repository_urls["api"]}:latest"
  web_image        = "${module.ecr.repository_urls["web"]}:latest"
  ai_service_image = "${module.ecr.repository_urls["ai-service"]}:latest"

  tags = local.common_tags
}
