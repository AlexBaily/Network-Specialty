#Global
region   = "eu-west-1"

#Network
name           = "VPN test VPC"
vpc_cidr       = "172.20.0.0/16"
cidrs          = "172.20.1.0/24,172.20.2.0/24,172.20.3.0/24"
priv_cidrs     = "172.20.4.0/24,172.20.5.0/24,172.20.6.0/24"
azs            = "eu-west-1a,eu-west-1b,eu-west-1c"
static_vpn     = true
