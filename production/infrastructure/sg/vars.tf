// 10.92.116.0 to 10.92.116.15

variable "prod-priv-1a" {
  description = "internal net for ec2 instances in prod-priv-1a"
  type = string
  default = "10.92.116.0/28"
}

// 10.92.116.16 to 10.92.116.31
variable "prod-priv-1b" {
  description = "internal net for ec2 instances in prod-priv-1b"
  type = string
  default = "10.92.116.16/28"
}

// 10.92.116.32 to 10.92.116.63
variable "prod-priv-1c" {
  description = "internal net for ec2 instances in prod-priv-1c"
  type = string
  default = "10.92.116.32/27"
}

variable "prod-pub-1abc" {
  description = "public net for ALB"
  type = string
  default = "10.92.118.0/24"
}
