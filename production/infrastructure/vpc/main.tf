resource "aws_vpc" "cu-sha-it-vpc" {
  cidr_block = "10.92.116.0/22"

  tags = {
    Name = "cu-sha-it-vpc"
  }
}

resource "aws_subnet" "Redis" {
  cidr_block        = "10.92.119.0/24"
  vpc_id            = aws_vpc.cu-sha-it-vpc.id
  availability_zone = "us-east-1e"

  tags = {
    Name = "Redis"
  }
}

resource "aws_subnet" "rds" {
  cidr_block        = "10.92.116.128/27"
  vpc_id            = aws_vpc.cu-sha-it-vpc.id
  availability_zone = "us-east-1e"

  tags = {
    Name = "Redis"
  }
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "redis-cache-subnet"
  subnet_ids = [aws_subnet.Redis.id]
}

resource "aws_rds_subnet_group" "rds" {
  name       = "redis-cache-subnet"
  subnet_ids = [aws_subnet.rds.id]
}