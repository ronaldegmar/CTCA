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
    key            = "production/alb/terraform.tfstate"
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

data "terraform_remote_state" "ec2" {
  backend = "s3"
  config = {
    bucket = "iac-state-s3"
    key    = "production/ec2/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_alb" "alb-1" {
  name            = "alb-1"
  subnets         = [data.terraform_remote_state.vpc.outputs.Subnet-Web-Public]
  security_groups = [data.terraform_remote_state.sg.outputs.Sg_ALB1]
  load_balancer_type = "application"
  tags {
    Name    = "alb-1"
  }
  access_logs {
    bucket = var.s3_bucket1
    prefix = "ALB1-logs"
  }
}

resource "aws_alb" "alb-2" {
  name            = "alb-2"
  subnets         = [data.terraform_remote_state.vpc.outputs.Subnet-Web-Public]
  security_groups = [data.terraform_remote_state.sg.outputs.Sg_ALB2]
  load_balancer_type = "application"
  tags {
    Name    = "alb-2"
  }
  access_logs {
    bucket = var.s3_bucket2
    prefix = "ALB2-logs"
  }
}

resource "aws_alb_target_group" "alb1_target_group" {
  name     = "alb1_target_group"
  port     = "443"
  protocol = "HTTPS"
  vpc_id   = data.terraform_remote_state.vpc.outputs.cu-sha-it-vpc
  tags {
    name = "alb1_target_group"
  }
}

resource "aws_alb_target_group" "alb2_target_group" {
  name     = "alb2_target_group"
  port     = "443"
  protocol = "HTTPS"
  vpc_id   = data.terraform_remote_state.vpc.outputs.cu-sha-it-vpc
  tags {
    name = "alb2_target_group"
  }
}

resource "aws_alb_listener" "alb1_listener" {
  load_balancer_arn = aws_alb.alb-1.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    target_group_arn = aws_alb_target_group.alb1_target_group.arn
    type             = "forward"
  }
}

resource "aws_alb_listener" "alb2_listener" {
  load_balancer_arn = aws_alb.alb-2.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    target_group_arn = aws_alb_target_group.alb2_target_group.arn
    type             = "forward"
  }
}

#Instance Attachment
resource "aws_alb_target_group_attachment" "alb1_tga" {
  target_group_arn = aws_alb_target_group.alb1_target_group.arn
  target_id        = data.terraform_remote_state.ec2.outputs.prod-priv-1a-ip[0]
  port             = 443
}

#Instance Attachment
resource "aws_alb_target_group_attachment" "alb2_tga1a" {
  target_group_arn = aws_alb_target_group.alb2_target_group.arn
  target_id        = data.terraform_remote_state.ec2.outputs.prod-priv-1a-ip[1]
  port             = 443
}

resource "aws_alb_target_group_attachment" "alb2_tga1b" {
  target_group_arn = aws_alb_target_group.alb2_target_group.arn
  target_id        = data.terraform_remote_state.ec2.outputs.prod-priv-1b-ip
  port             = 443
}

resource "aws_alb_target_group_attachment" "alb2_tga1c" {
  target_group_arn = aws_alb_target_group.alb2_target_group.arn
  target_id        = data.terraform_remote_state.ec2.outputs.prod-priv-1c-ip
  port             = 443
}