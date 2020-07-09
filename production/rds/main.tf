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
    key            = "production/rds/terraform.tfstate"
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

data "vault_generic_secret" "redis" {
  path = "secret/redis"
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = data.vault_generic_secret.redis.data["username"]
  password             = data.vault_generic_secret.redis.data["password"]
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids = [data.terraform_remote_state.sg.outputs.Sg_RDS_Servers]
  db_subnet_group_name = data.terraform_remote_state.vpc.outputs.rds-subnet
}