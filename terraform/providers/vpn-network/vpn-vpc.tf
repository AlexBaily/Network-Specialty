#Main terraform file for VPN and Network testing environment


variable "region"         {}
variable "name"           {}
variable "vpc_cidr"       {}
variable "cidrs"          {} 
variable "priv_cidrs"     {}
variable "azs"            {}
variable "vpn_ip_address" {}
variable "static_vpn"     {}
provider "aws" {
  region = "${var.region}"
}


module "network" {
  source = "../../modules/vpc"

  environment_name = "${var.name}"
  vpc_cidr         = "${var.vpc_cidr}"
  azs              = "${var.azs}"
  priv_cidrs       = "${var.priv_cidrs}"
  cidrs            = "${var.cidrs}"
  vpn_ip_address   = "${var.vpn_ip_address}"
  static_vpn       = "${var.static_vpn}"
}
