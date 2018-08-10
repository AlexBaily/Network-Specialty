#Terraform Network Module

variable "environment_name" {}
variable "vpc_cidr"         {}
variable "cidrs"            {}
variable "priv_cidrs"       {}
variable "azs"              {}
variable "vpn_ip_address"   {}
variable "static_vpn"       {}


resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags { Name = "${var.environment_name}" } 
}

resource "aws_internet_gateway" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags { Name = "${var.environment_name}" }
}


resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(split(",", var.cidrs), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  count             = "${length(split(",", var.cidrs))}"

  tags { Name = "${var.environment_name} ${element(split(",", var.azs), count.index)}" }
}

resource "aws_route_table" "public" {
  vpc_id           = "${aws_vpc.vpc.id}"
  propagating_vgws = ["${aws_vpn_gateway.vgw.id}"]
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.public.id}"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(split(",", var.priv_cidrs), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  count             = 3

  tags { Name = "${var.environment_name} Private ${element(split(",", var.azs), count.index)}" }
}

resource "aws_route_table" "private" {
  vpc_id           = "${aws_vpc.vpc.id}"
  propagating_vgws = ["${aws_vpn_gateway.vgw.id}"]

}

resource "aws_route_table_association" "private_routes" {
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
  count          = 3
}

resource "aws_vpn_gateway" "vgw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "VGW to main VPC"
  }
}

resource "aws_customer_gateway" "cgw" {
  bgp_asn = 65000
  ip_address = "${var.vpn_ip_address}"
  type = "ipsec.1"
 
  tags {
    Name = "CGW to main VPC"
  }
}

resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = "${aws_vpn_gateway.vgw.id}"
  customer_gateway_id = "${aws_customer_gateway.cgw.id}"
  type                = "ipsec.1"
  static_routes_only  = "${var.static_vpn}"
}

resource "aws_vpn_connection_route" "Main_VPC" {
  destination_cidr_block = "10.0.0.0/24"
  vpn_connection_id      = "${aws_vpn_connection.main.id}"
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = "${aws_vpc.vpc.id}"
  service_name        = "com.amazonaws.eu-west-1.ec2"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true 

  security_group_ids = [
    "${aws_security_group.ec2_end.id}"
  ]
}

resource "aws_security_group" "ec2_end" {
  name   = "EC2 Interface Endpoint"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["172.20.0.0/16"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

}

output "vpc-id"     { value = "${aws_vpc.vpc.id}" }
output "subnet_ids" { value = "${join(",", aws_subnet.public.*.id)}" }
