variable "ami" {
  type    = string
  default = "ami-0a313d6098716f372" // ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20190212.1
}

variable "instance-type" {
  type    = string
  default = "t2.small"
}

variable "instance-volume-size" {
  type    = string
  default = "8"
}

variable "tag-name-1a" {
  type    = string
  default = "node1a"
}

variable "tag-name-1b" {
  type    = string
  default = "node1b"
}

variable "tag-name-1c" {
  type    = string
  default = "node1c"
}

variable "AZA" {
  type = string
  default = "AZA"
}

variable "AZB" {
  type = string
  default = "AZB"
}

variable "AZC" {
  type = string
  default = "AZC"
}