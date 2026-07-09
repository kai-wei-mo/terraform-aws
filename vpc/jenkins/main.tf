module "network" {
  source = "../modules/network"

  name                = local.name
  vpc_cidr            = local.vpc_cidr
  public_subnet_cidr  = local.public_subnet_cidr
  private_subnet_cidr = local.private_subnet_cidr
  availability_zone   = local.availability_zone
}
