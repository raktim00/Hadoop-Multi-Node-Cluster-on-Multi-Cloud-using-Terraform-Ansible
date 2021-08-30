variable "aws-vpc-cidr-block" {
  type = string
  default = "10.2.0.0/16"
}

variable "aws-availability-zone" {
  type = string
  default = "ap-south-1b"
}

variable "aws-subnet-cidr-block" {
  type = string
  default = "10.2.0.0/24"
}

variable "aws-key-name" {
  type = string
  default = "aws-hadoop-key"
}

variable "aws-instance-type" {
  type = string
  default = "t2.medium"
}

variable "aws-instance-name" {
  type = list
  default = ["hadoop-namenode","hadoop-jobtracker"]
}