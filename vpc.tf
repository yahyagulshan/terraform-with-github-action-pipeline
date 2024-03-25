provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  # name   = "ex-${basename(path.cwd)}"
  # name   = "test-vpc-staging-env"
  name   = "yahya-test-vpc"
  region = "us-east-1"

  vpc_cidr = "16.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 1)


  # tags = {
  #   Example    = local.name
  #   GithubRepo = "terraform-aws-vpc"
  #   GithubOrg  = "terraform-aws-modules"
  # }
}

################################################################################
# VPC Module (for Simple Vpc creation)
################################################################################

module "vpc" {
  # source = "../../"
  source = "./modules/vpc-simple/"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
 
  # private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 2, k + 1)]
  # public_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 1, k + 1)]

  # tags = local.tags
}


