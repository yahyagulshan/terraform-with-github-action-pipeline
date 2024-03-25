module "vpc" {
  source = "./modules/aws-vpc"

  name = "staging-vpc-1"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # enable_nat_gateway = false
  # enable_vpn_gateway = false
   

  tags = {
    Terraform = "true"
    Environment = "staging"
  }
}

# resource "aws_eip" "nat" {
#   count = 1

#   vpc = true
# }

locals {
  name   = "complete-example"
  region = "us-east-1"
  tags = {
    Owner       = "user"
    Environment = "staging"
    Name        = "complete"
  }
}

module "vpc1" {
  source = "./modules/aws-vpc"

  name = local.name
  cidr = "20.10.0.0/16" # 10.0.0.0/8 is reserved for EC2-Classic

  azs                 = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets     = ["20.10.1.0/24", "20.10.2.0/24", "20.10.3.0/24"]
  public_subnets      = ["20.10.11.0/24", "20.10.12.0/24", "20.10.13.0/24"]
  database_subnets    = ["20.10.21.0/24", "20.10.22.0/24", "20.10.23.0/24"]
  elasticache_subnets = ["20.10.31.0/24", "20.10.32.0/24", "20.10.33.0/24"]
  redshift_subnets    = ["20.10.41.0/24", "20.10.42.0/24", "20.10.43.0/24"]
  intra_subnets       = ["20.10.51.0/24", "20.10.52.0/24", "20.10.53.0/24"]

  create_database_subnet_group = false

  manage_default_network_acl = true
  default_network_acl_tags   = { Name = "${local.name}-default" }

  manage_default_route_table = true
  default_route_table_tags   = { Name = "${local.name}-default" }

  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_classiclink             = true
  enable_classiclink_dns_support = true

  enable_nat_gateway = true
  single_nat_gateway = true

#   customer_gateways = {
#     IP1 = {
#       bgp_asn     = 65112
#       ip_address  = "1.2.3.4"
#       device_name = "some_name"
#     },
#     IP2 = {
#       bgp_asn    = 65112
#       ip_address = "5.6.7.8"
#     }
#   }
# }
  # enable_vpn_gateway = true

  # enable_dhcp_options              = true
  # dhcp_options_domain_name         = "service.consul"
  # dhcp_options_domain_name_servers = ["127.0.0.1", "10.10.0.2"]

  # # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  # enable_flow_log                      = true
  # create_flow_log_cloudwatch_log_group = true
  # create_flow_log_cloudwatch_iam_role  = true
  # flow_log_max_aggregation_interval    = 60

  # tags = local.tags


# data "aws_security_group" "default" {
#   name   = "default"
#   vpc_id = module.vpc.vpc_id
# }

# data "aws_iam_policy_document" "dynamodb_endpoint_policy" {
#   statement {
#     effect    = "Deny"
#     actions   = ["dynamodb:*"]
#     resources = ["*"]

#     principals {
#       type        = "*"
#       identifiers = ["*"]
#     }

#     condition {
#       test     = "StringNotEquals"
#       variable = "aws:sourceVpce"

#       values = [module.vpc.vpc_id]
#     }
#   }
}

data "aws_iam_policy_document" "generic_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpc"

      values = [module.vpc.vpc_id]
    }
  }
}

resource "aws_security_group" "vpc_tls" {
  name_prefix = "${local.name}-vpc_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  tags = local.tags
}