#Main terraform file for VPN and Network testing environment


variable "region"       {}
variable "name"         {}
variable "vpc_cidr"     {}
variable "cidrs"        {} 
variable "azs"          {}
variable "vpn_ip_address" {}
provider "aws" {
  region = "${var.region}"
}


module "network" {
  source = "../../modules/vpc"

  environment_name = "${var.name}"
  vpc_cidr         = "${var.vpc_cidr}"
  azs              = "${var.azs}"
  cidrs            = "${var.cidrs}"
  vpn_ip_address   = "${var.vpn_ip_address}"

}
