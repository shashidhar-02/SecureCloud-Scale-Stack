module "vpc" {
  source             = "../../modules/vpc"
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  database_subnets   = var.database_subnets
  single_nat_gateway = true # Save costs in Dev
  tags               = var.tags
}

module "security" {
  source      = "../../modules/security"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  tags        = var.tags
}

module "alb" {
  source                     = "../../modules/alb"
  environment                = var.environment
  vpc_id                     = module.vpc.vpc_id
  public_subnet_ids          = module.vpc.public_subnet_ids
  security_group_id          = module.security.alb_sg_id
  certificate_arn            = var.certificate_arn
  enable_deletion_protection = false # Dev environment
  tags                       = var.tags
}

module "eks" {
  source                    = "../../modules/eks"
  environment               = var.environment
  cluster_version           = var.eks_cluster_version
  private_subnet_ids        = module.vpc.private_subnet_ids
  cluster_security_group_id = module.security.eks_cluster_sg_id
  kms_key_arn               = module.security.kms_key_arn
  public_access_cidrs       = var.public_access_cidrs
  instance_types            = var.eks_instance_types
  desired_size              = var.eks_desired_size
  min_size                  = var.eks_min_size
  max_size                  = var.eks_max_size
  tags                      = var.tags
}

module "rds" {
  source                  = "../../modules/rds"
  environment             = var.environment
  engine_version          = var.rds_engine_version
  instance_class          = var.rds_instance_class
  allocated_storage       = var.rds_allocated_storage
  db_username             = var.db_username
  db_subnet_group_name    = module.vpc.database_subnet_group_name
  rds_security_group_id   = module.security.rds_sg_id
  kms_key_arn             = module.security.kms_key_arn
  multi_az                = false # Dev environment
  deletion_protection     = false # Dev environment
  backup_retention_period = 1     # Dev environment
  tags                    = var.tags
}
