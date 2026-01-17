terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
  }

  # backend "s3" {
  #     bucket         = "starttech-AWSID-tfstate"
  #     key            = "prod/terraform.tfstate"
  #     region         = var.region
  #     encrypt        = true
  #     dynamodb_table = "starttech-tflocks"
  # }

  required_version = ">= 1.10"
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/networking/vpc"

  project_name         = var.project_name
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "security_groups" {
  source = "./modules/networking/security-groups"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

module "iam" {
  source = "./modules/compute/IAM"

  project_name = var.project_name
}

module "autoscaling" {
  source = "./modules/compute/autoscaling"

  project_name      = var.project_name
  private_subnet_ids = module.vpc.private_subnet_ids
  instance_type         = var.instance_type
  instance_profile_name = module.iam.instance_profile_name
  instance_sg_id        = module.security_groups.instance_sg_id
  desired_capacity      = var.desired_capacity
  max_size              = var.max_size
  min_size              = var.min_size
  target_group_arn      = module.load_balancer.alb_tg_arn
}

module "load_balancer" {
  source = "./modules/compute/load-balancer"

  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security_groups.alb_sg_id
}

module "s3" {
  source = "./modules/storage/s3-bucket"

  project_name                = var.project_name
  cloudfront_distribution_arn = module.cloudfront.distribution_arn
}

module "cloudfront" {
  source = "./modules/storage/cloudfront"

  project_name                   = var.project_name
  s3_bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  origin_id                      = "s3-${module.s3.bucket_id}"
}

module "cloudwatch" {
  source = "./modules/monitoring/cloudwatch"

  project_name                       = var.project_name
  redis_cloudwatch_retention_in_days = var.redis_cloudwatch_retention_in_days
}

module "redis" {
  source = "./modules/storage/redis"

  project_name                   = var.project_name
  private_subnet_ids             = module.vpc.private_subnet_ids
  redis_sg_id                    = module.security_groups.redis_sg_id
  redis_engine_version           = var.redis_engine_version
  redis_node_type                = var.redis_node_type
  redis_num_node_grps            = var.redis_num_node_grps
  redis_replicas_per_node_grp    = var.redis_replicas_per_node_grp
  redis_snapshot_retention_limit = var.redis_snapshot_retention_limit
  redis_snapshot_window          = var.redis_snapshot_window
  redis_maintenance_window       = var.redis_maintenance_window
  cloudwatch_log_grp_name        = module.cloudwatch.redis_cloudwatch_log_grp_name
}

module "ecr" {
  source = "./modules/storage/ecr"

  project_name                = var.project_name
  ecr_image_retention_count   = var.ecr_image_retention_count
}
