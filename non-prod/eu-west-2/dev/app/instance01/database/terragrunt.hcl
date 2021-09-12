terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-rds"
}

include {
  path = find_in_parent_folders()
}

locals {
  app_vars      = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  instance_vars = read_terragrunt_config(find_in_parent_folders("instance.hcl"))
  network_vars  = read_terragrunt_config(find_in_parent_folders("network.hcl"))
  env_vars      = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "rds-security-group" {
  config_path = "../rds-security-group"
}

inputs = {
  identifier           = join("-", [local.app_vars.locals.name,local.instance_vars.locals.name,local.env_vars.locals.name])
  engine               = "mysql"
  engine_version       = "5.7.33"
  family               = "mysql5.7"
  major_engine_version = "5.7"
  instance_class       = "db.t2.small"

  allocated_storage     = 5
  max_allocated_storage = 10


  name     = "example"
  username = "root"
  password = "test12345"
  port     = 3306

  multi_az               = false
  subnet_ids             = local.network_vars.locals.subnets

  vpc_security_group_ids = [dependency.rds-security-group.outputs.security_group_id]

}
