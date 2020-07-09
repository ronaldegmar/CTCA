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
    key            = "production/elb/terraform.tfstate"
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

resource "aws_elb" "elb" {
  name = "elb"
  availability_zones = [var.AZB]
  security_groups = [data.terraform_remote_state.sg.outputs.Sg_ELB]


  listener {
    instance_port = 443
    instance_protocol = "https"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  }

  listener {
    instance_port = 8984
    instance_protocol = "tcp"
    lb_port = 8984
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 8984
    instance_protocol = "tcp"
    lb_port = 8984
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 8444
    instance_protocol = "tcp"
    lb_port = 8444
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 8445
    instance_protocol = "tcp"
    lb_port = 8445
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 8446
    instance_protocol = "tcp"
    lb_port = 8446
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 8447
    instance_protocol = "tcp"
    lb_port = 8447
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 8448
    instance_protocol = "tcp"
    lb_port = 8448
    lb_protocol = "tcp"
  }
}