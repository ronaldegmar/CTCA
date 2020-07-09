provider "aws" {
  version = "2.12.0"
  region  = "us-east-1"
}

provider "vault" {
  # It is strongly recommended to configure this provider through the
  # environment variables described above, so that each user can have
  # separate credentials set in the environment.
  #
  # This will default to using $VAULT_ADDR
  # But can be set explicitly
  address = "https://vault.mycompany.com:8200"
}

provider "null" {
  version = "2.1.2"
}

terraform {
  backend "s3" {
    bucket         = "iac-state-s3"
    key            = "production/redis/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = "true"
    dynamodb_table = "iac-state-locks"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "iac-state-s3"
    key    = "production/infrastructure/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "sg" {
  backend = "s3"
  config = {
    bucket = "iac-state-s3"
    key    = "production/infrastructure/sg/terraform.tfstate"
    region = "us-east-1"
  }
}


resource "aws_elasticache_cluster" "myredis" {
  cluster_id           = "cluster-example"
  engine               = "redis"
  node_type            = "cache.m4.large"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
  subnet_group_name    = data.terraform_remote_state.vpc.outputs.redis-subnet
  security_group_ids = [data.terraform_remote_state.sg.outputs.Sg_ElasticCacheRedis]
}