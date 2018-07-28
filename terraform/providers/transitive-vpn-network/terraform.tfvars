#Global
region   = "eu-west-1"

#Network
name           = "Transitive VPN test VPC"
vpc_cidr       = "172.23.0.0/16"
cidrs          = "172.23.1.0/24,172.23.2.0/24,172.23.3.0/24"
azs            = "eu-west-1a,eu-west-1b,eu-west-1c"
static_vpn     = false
