// create a virtual private cloud
resource "aws_vpc" "compucorp_vpc" {
  cidr_block        = "192.168.0.0/21"
  instance_tenancy  = "default"
  enable_dns_hostnames = true

  tags {
    Name = "compucorp_vpc"
  }
}

// public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id              = "${aws_vpc.compucorp_vpc.id}"
  cidr_block          = "192.168.0.16/28"
  availability_zone   = "us-east-2b"

  tags  {
    Name = "compucorp subnet A"
  }
}

// public subnet in a different zone
resource "aws_subnet" "public_subnet_zone2" {
  vpc_id              = "${aws_vpc.compucorp_vpc.id}"
  cidr_block          = "192.168.0.32/28"
  availability_zone   = "us-east-2c"

  tags  {
    Name = "compucorp subnet B"
  }
}

// route table for public subnet
resource "aws_route_table" "compucorp_rt" {
  vpc_id  = "${aws_vpc.compucorp_vpc.id}"

  tags {
    Name  = "compucorp route_table"
  }
}

// Create an internet gateway for VPC to send traffic out
resource "aws_internet_gateway" "compucorp_gateway" {
  vpc_id  = "${aws_vpc.compucorp_vpc.id}"

  tags {
    Name = "compucorp internet_gateway"
  }
}

// edit route table to include internet gateway
resource "aws_route" "compucorp_rt" {
  gateway_id              = "${aws_internet_gateway.compucorp_gateway.id}"
  route_table_id          = "${aws_route_table.compucorp_rt.id}"
  destination_cidr_block  = "0.0.0.0/0"
}

// public subnet association with route table
resource "aws_route_table_association" "cp_public" {
  subnet_id       = "${aws_subnet.public_subnet.id}"
  route_table_id  = "${aws_route_table.compucorp_rt.id}"
}