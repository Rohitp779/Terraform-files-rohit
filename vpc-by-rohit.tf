provider "aws" {
  region     = var.region
  access_key = var.acckey
  secret_key = var.seckey
}

resource "aws_vpc" "test" {
  cidr_block       = "10.10.0.0/16"

  tags = {
    Name = "test"
  }
}
resource "aws_subnet" "subnet-1" {
  vpc_id     = "${aws_vpc.test.id}"
  cidr_block = "10.10.1.0/24"
  availability_zone= "us-east-1c"
  tags = {
    Name = "subnet-1"
  }
}

resource "aws_subnet" "subnet-2" {
  vpc_id     = "${aws_vpc.test.id}"
  cidr_block = "10.10.2.0/24"
  availability_zone= "us-east-1d"
  tags = {
    Name = "subnet-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.test.id}"

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "pub-rt" {
  vpc_id = "${aws_vpc.test.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
}
  tags = {
    Name = "pub-rt"
  }
}

resource "aws_route_table_association" "one" {
  subnet_id      = "${aws_subnet.subnet-1.id}"
  route_table_id = "${aws_route_table.pub-rt.id}"
}

resource "aws_route_table_association" "two" {
  subnet_id      = "${aws_subnet.subnet-2.id}"
  route_table_id = "${aws_route_table.pub-rt.id}"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.test.id}"

  ingress {
    description      = "all from VPC"
    from_port        = 22
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

resource "aws_instance" "instance1_public" {
      ami ="ami-018ba43095ff50d08"
      associate_public_ip_address = true
      availability_zone = "us-east-1c"
      key_name = "rohit"
      instance_type = "t2.micro"
      subnet_id = "${aws_subnet.subnet-1.id}"
      vpc_security_group_ids = [aws_security_group.allow_all.id]
}

