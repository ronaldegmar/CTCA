provider "aws" {
  version = "2.12.0"
  region  = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "iac-state-s3"
    key            = "production/infrastructure/sg/terraform.tfstate"
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

resource "aws_security_group" "Private_Web_Servers" {
  name        = "Private Web Servers"
  description = "https access for private web servers"
  vpc_id      = data.terraform_remote_state.vpc.outputs.cu-sha-it-vpc

  ingress {
    from_port = 443
    protocol  = "TCP"
    to_port   = 443
    security_groups = [aws_security_group.aws_alb1.id,aws_security_group.aws_alb2.id, aws_security_group.aws_elb.id]
  }

  ingress {
    from_port = 8994
    protocol  = "TCP"
    to_port   = 8994
    security_groups = [aws_security_group.aws_elb.id]
  }

  ingress {
    from_port = 8444
    protocol  = "TCP"
    to_port   = 8448
    security_groups = [aws_security_group.aws_elb.id]
  }

  egress {
    from_port   = 1433
    protocol    = "TCP"
    to_port     = 1433
    cidr_blocks = [
      var.prod-priv-1a,
      var.prod-priv-1b,
      var.prod-priv-1c,
    ]
  }

  egress {
    from_port = 8994
    protocol  = "TCP"
    to_port   = 8994
    security_groups = [aws_security_group.aws_elb.id]
  }

  egress {
    from_port = 8444
    protocol  = "TCP"
    to_port   = 8448
    security_groups = [aws_security_group.aws_elb.id]
  }

  egress {
    from_port = 6379
    protocol  = "TCP"
    to_port   = 6379
    security_groups = [aws_security_group.ElasticCacheRedis.id]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "Private Web Servers"
  }
}

resource "aws_security_group" "ElasticCacheRedis" {
  name        = "Elastic Cache Redia"
  description = "Access to Redis"
  vpc_id      = data.terraform_remote_state.vpc.outputs.cu-sha-it-vpc

  ingress {
    from_port = 6379
    protocol  = "TCP"
    to_port   = 6379
    cidr_blocks = [
      var.prod-priv-1c,
      var.prod-priv-1a,
    ]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Private Web Servers"
  }
}

resource "aws_security_group" "RDS_Servers" {
  name        = "RDS Servers"
  description = "for RDS servers"
  vpc_id      = data.terraform_remote_state.vpc.outputs.cu-sha-it-vpc

  ingress {
    from_port = 1433
    protocol  = "tcp"
    to_port   = 1433
    cidr_blocks = [
      var.prod-priv-1a,
      var.prod-priv-1b,
      var.prod-priv-1c,
    ]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Postgres Servers"
  }
}

resource "aws_security_group" "aws_elb" {
  name = "ELB SG"
  description = "for ELB"
  vpc_id      = data.terraform_remote_state.vpc.outputs.cu-sha-it-vpc

  ingress {
    from_port = 443
    protocol  = "TCP"
    to_port   = 443
    cidr_blocks = [
      var.prod-priv-1b,
    ]
  }

  ingress {
    from_port = 8994
    protocol  = "TCP"
    to_port   = 8994
    cidr_blocks = [
      var.prod-priv-1a,
      var.prod-priv-1c,
    ]
  }

  ingress {
    from_port = 8444
    protocol  = "TCP"
    to_port   = 8448
    cidr_blocks = [
      var.prod-priv-1a,
      var.prod-priv-1c,
    ]
  }

  egress {
    from_port = 443
    protocol  = "TCP"
    to_port   = 443
    cidr_blocks = [
      var.prod-priv-1b,
    ]
  }

  egress {
    from_port = 8994
    protocol  = "TCP"
    to_port   = 8994
    cidr_blocks = [
      var.prod-priv-1b,
    ]
  }

  egress {
    from_port = 8444
    protocol  = "TCP"
    to_port   = 8448
    cidr_blocks = [
      var.prod-priv-1b,
    ]
  }
}

resource "aws_security_group" "aws_alb1" {
  name = "ALB SG"
  description = "for ALB"
  vpc_id      = data.terraform_remote_state.vpc.outputs.cu-sha-it-vpc

  ingress {
    from_port = 443
    protocol  = "TCP"
    to_port   = 443
    cidr_blocks = [
      var.prod-priv-1a,
    ]
  }

  egress {
    from_port = 443
    protocol  = "TCP"
    to_port   = 443
    cidr_blocks = [
      var.prod-priv-1a,
    ]
  }
}

resource "aws_security_group" "aws_alb2" {
  name = "ALB SG"
  description = "for ALB"
  vpc_id      = data.terraform_remote_state.vpc.outputs.cu-sha-it-vpc

  ingress {
    from_port = 443
    protocol  = "TCP"
    to_port   = 443
    cidr_blocks = [
      var.prod-priv-1a,
      var.prod-priv-1b,
      var.prod-priv-1c,
    ]
  }

  egress {
    from_port = 443
    protocol  = "TCP"
    to_port   = 443
    cidr_blocks = [
      var.prod-priv-1a,
      var.prod-priv-1b,
      var.prod-priv-1c,
    ]
  }
}