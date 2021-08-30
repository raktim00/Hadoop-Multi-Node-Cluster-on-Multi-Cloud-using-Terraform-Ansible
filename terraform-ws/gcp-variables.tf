variable "gcp-subnet-cidr-block" {
  type = string
  default = "10.2.0.0/16"
}

variable "gcp-region" {
  type = string
  default = "asia-south1"
}

variable "gcp-zone" {
  type = string
  default = "asia-south1-b"
}

variable "gcp-machine-type" {
  type = string
  default = "n1-standard-1"
}

variable "gcp-instance-name" {
  type = list
  default = ["hadoop-datanode","hadoop-tasktracker"]
}