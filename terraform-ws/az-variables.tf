variable "az-location" {
  type = string
  default = "centralindia"
}

variable "az-vpc-cidr-block" {
  type = string
  default = "10.2.0.0/16"
}

variable "az-subnet-cidr-block" {
  type = string
  default = "10.2.0.0/24"
}

variable "az-key-name" {
  type = string
  default = "az-hadoop-key"
}

variable "az-instance-type" {
  type = string
  default = "Standard_B2s"
}

variable "az-instance-conf" {
  type = map
  default = {
    hadoop-datanode = {
      name = "hadoop-datanode",
      public-ip = "hadoop-datanode-ip"
      network-interface = "hadoop-datanode-ni"
      disk-name = "hadoop-datanode-disk"
    },
    hadoop-tasktracker = {
      name = "hadoop-tasktracker",
      public-ip = "hadoop-tasktracker-ip"
      network-interface = "hadoop-tasktracker-ni"
      disk-name = "hadoop-tasktracker-disk"
    }
  }
}