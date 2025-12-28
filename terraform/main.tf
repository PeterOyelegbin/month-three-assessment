terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
        tls = {
            source  = "hashicorp/tls"
            version = "~> 4.0"
        }
        local = {
            source  = "hashicorp/local"
            version = "~> 2.0"
        }
    }
    
    required_version = ">= 0.12"
}

# Configure the AWS Provider
provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
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

    vpc_id = module.vpc.vpc_id
    project_name = var.project_name
}

module "autoscaling" {
    source = "./modules/compute/autoscaling"

    project_name       = "${var.project_name}-backend"
    instance_type      = var.instance_type
    instance_sg_id     = module.security_groups.backend_sg_id
    availability_zones = var.availability_zones
    desired_capacity   = var.desired_capacity
    max_size           = var.max_size
    min_size           = var.min_size
}

module "load_balancer" {
    source = "./modules/compute/load-balancer"

    project_name = var.project_name
    vpc_id       = module.vpc.vpc_id
    public_subnet_ids = module.vpc.public_subnet_ids
    alb_sg_id    = module.security_groups.alb_sg_id
}
