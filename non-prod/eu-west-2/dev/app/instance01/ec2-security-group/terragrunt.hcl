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
  description = "EC2 Security group"

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "0.0.0.0/0"
    }
    ]

    egress_with_cidr_blocks = [
    {
      from_port  = 0
      to_port = 65535
      protocol = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
    ]

}
