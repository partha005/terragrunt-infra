terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-ec2-instance.git"
}

locals {
  app_vars      = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  instance_vars = read_terragrunt_config(find_in_parent_folders("instance.hcl"))
}

include {
  path = find_in_parent_folders()
}

dependency "ec2-security-group" {
  config_path = "../ec2-security-group"
}

inputs = {

  name         = join("-", [local.app_vars.locals.name,local.instance_vars.locals.name])

  ami                    = "ami-09a56048b08f94cdf"
  instance_type          = "t2.micro"
  key_name               = "ssh-key-pair"   # SSH key-pair needs to be created beforehand
  monitoring             = true
  vpc_security_group_ids = [dependency.ec2-security-group.outputs.security_group_id]
  #subnet_id              = ""

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
