locals {
  aws_region        = "us-east-1"
  availability_zone = "us-east-1a"
  name              = "jenkins"

  vpc_cidr            = "10.50.0.0/24"
  public_subnet_cidr  = "10.50.0.0/27"  # NAT gateway
  private_subnet_cidr = "10.50.0.32/27" # private workloads (e.g. Jenkins EC2 agents)
}
