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
    key            = "production/ec2/terraform.tfstate"
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

data "terraform_remote_state" "elb" {
  backend = "s3"
  config = {
    bucket = "iac-state-s3"
    key    = "production/elb/terraform.tfstate"
    region = "us-east-1"
  }
}


data "vault_generic_secret" "generic-pem" {
  path = "secret/pem/${var.tag-name}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "prod-priv-1a" {
  count                  = 3
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance-type
  vpc_security_group_ids = [data.terraform_remote_state.sg.outputs.Sg_Private_Web_Servers]
  subnet_id              = data.terraform_remote_state.vpc.outputs.Subnet-Web-Private
  key_name               = var.tag-name-1a
  availability_zone      = var.AZA

  root_block_device {
    volume_size = var.instance-volume-size
  }

  lifecycle {
    ignore_changes = [ami]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.private_ip
    private_key = data.vault_generic_secret.generic-pem.data["pem"]
  }

  tags = {
    Name = format("${var.tag-name-1a}-%d", count.index)
  }
}

resource "aws_launch_configuration" "elb-launch-config" {
  image_id = var.ami
  instance_type = var.instance-type
  security_groups = [data.terraform_remote_state.sg.outputs.Sg_Private_Web_Servers]
  user_data = <<-EOF
              #!/bin/bash
              echo "Testing" > index.html
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "elb_asg" {
  launch_configuration = aws_launch_configuration.elb-launch-config.id
  max_size = 1
  min_size = 1
  availability_zones = [
    var.AZB
  ]
  load_balancers = [data.terraform_remote_state.elb.outputs.elb]

  tag {
    key    = "Name"
    value  = "elb-asg"
    propagate_at_launch = true
  }
}


resource "aws_instance" "prod-priv-1b" {
  count                  = 1
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance-type
  vpc_security_group_ids = [data.terraform_remote_state.sg.outputs.Sg_Private_Web_Servers]
  subnet_id              = data.terraform_remote_state.vpc.outputs.Subnet-Web-Private
  key_name               = var.tag-name-1b
  availability_zone      = var.AZB

  root_block_device {
    volume_size = var.instance-volume-size
  }

  lifecycle {
    ignore_changes = [ami]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.private_ip
    private_key = data.vault_generic_secret.generic-pem.data["pem"]
  }

  tags = {
    Name = format("${var.tag-name-1b}-%d", count.index)
  }
}

resource "aws_instance" "prod-priv-1c" {
  count                  = 1
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance-type
  vpc_security_group_ids = [data.terraform_remote_state.sg.outputs.Sg_Private_Web_Servers]
  subnet_id              = data.terraform_remote_state.vpc.outputs.Subnet-Web-Private
  key_name               = var.tag-name-1c
  availability_zone      = var.AZC

  root_block_device {
    volume_size = var.instance-volume-size
  }

  lifecycle {
    ignore_changes = [ami]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.private_ip
    private_key = data.vault_generic_secret.generic-pem.data["pem"]
  }

  tags = {
    Name = format("${var.tag-name-1c}-%d", count.index)
  }
}