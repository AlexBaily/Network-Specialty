#Terraform Network Module

variable "environment_name" {}
variable "vpc_cidr"         {}
variable "cidrs"            {}
variable "azs"              {}
variable "vpn_ip_address"   {}


resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  
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
  vpc_id = "${aws_vpc.vpc.id}"

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.public.id}"
  }
}

resource "aws_vpn_gateway" "vpg" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "VPG to main VPC"
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
  vpn_gateway_id      = "${aws_vpn_gateway.vpg.id}"
  customer_gateway_id = "${aws_customer_gateway.cgw.id}"
  type                = "ipsec.1"
  static_routes_only  = true
}

resource "aws_vpn_connection_route" "Main_VPC" {
  destination_cidr_block = "10.0.0.0/24"
  vpn_connection_id      = "${aws_vpn_connection.main.id}"
}

output "vpc-id"     { value = "${aws_vpc.vpc.id}" }
output "subnet_ids" { value = "${join(",", aws_subnet.public.*.id)}" }
