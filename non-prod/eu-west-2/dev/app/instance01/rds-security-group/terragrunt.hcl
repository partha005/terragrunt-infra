terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-security-group.git"
}

locals {
  app_vars      = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  instance_vars = read_terragrunt_config(find_in_parent_folders("instance.hcl"))
  env_vars      = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

include {
  path = find_in_parent_folders()
}


inputs = {
  name        = join("-", [local.app_vars.locals.name,local.instance_vars.locals.name,local.env_vars.locals.name])
  description = "RDS Security group"

  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MYSQL port"
      cidr_blocks = "0.0.0.0/0"
    }
    ]

}
