resource "aws_vpc" "aws_hadoop_vnet" {
  cidr_block = var.aws-vpc-cidr-block
  tags = {
    Name = "aws-hadoop-network"
  }
}

resource "aws_internet_gateway" "aws_hadoop_igw" {

  depends_on = [
    aws_vpc.aws_hadoop_vnet
  ]

  vpc_id = aws_vpc.aws_hadoop_vnet.id
  tags = {
    Name = "aws-hadoop-igw"
  }
}

resource "aws_subnet" "aws_hadoop_subnet" {

  depends_on = [
    aws_vpc.aws_hadoop_vnet
  ]

  vpc_id     = aws_vpc.aws_hadoop_vnet.id
  availability_zone = var.aws-availability-zone
  cidr_block = var.aws-subnet-cidr-block
  map_public_ip_on_launch = true
  tags = {
    Name = "aws-hadoop-subnet"
  }
}

resource "aws_route_table" "aws_hadoop_rt" {

  depends_on = [
    aws_vpc.aws_hadoop_vnet,
    aws_internet_gateway.aws_hadoop_igw
  ]

  vpc_id = aws_vpc.aws_hadoop_vnet.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_hadoop_igw.id
  }
  tags = {
    Name = "aws-hadoop-rt"
  }
}

resource "aws_route_table_association" "aws_hadoop_subnet_rt" {

  depends_on = [
    aws_subnet.aws_hadoop_subnet,
    aws_route_table.aws_hadoop_rt
  ]

  subnet_id      = aws_subnet.aws_hadoop_subnet.id
  route_table_id = aws_route_table.aws_hadoop_rt.id
}

resource "aws_security_group" "aws_hadoop_sg" {

  depends_on = [
    aws_vpc.aws_hadoop_vnet
  ]

  name        = "aws-allowall-sg"
  description = "Allow All inbound TCP traffic"
  vpc_id      = aws_vpc.aws_hadoop_vnet.id

  ingress {
    description      = "Allow All TCP"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "aws_hadoop_key" {
  key_name   = var.aws-key-name
  public_key = file("../hadoop-multi-cloud-key-public.pub")
  }

resource "aws_instance" "aws_hadoop_master" {

  depends_on = [
    aws_key_pair.aws_hadoop_key,
    aws_subnet.aws_hadoop_subnet,
    aws_security_group.aws_hadoop_sg,
  ]

  ami = "ami-0e6837d3d816a2ac6"
  instance_type = var.aws-instance-type
  key_name = aws_key_pair.aws_hadoop_key.key_name
  vpc_security_group_ids = [ "${aws_security_group.aws_hadoop_sg.id}" ]
  subnet_id = aws_subnet.aws_hadoop_subnet.id
  count = length(var.aws-instance-name)
  
  tags = {
    "Name" = var.aws-instance-name[count.index]
  }
}