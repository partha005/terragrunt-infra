terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-ec2-instance.git"
}

locals {
  app_vars      = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  instance_vars = read_terragrunt_config(find_in_parent_folders("instance.hcl"))
  env_vars      = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

include {
  path = find_in_parent_folders()
}

dependency "ec2-security-group" {
  config_path = "../ec2-security-group"
}

dependency "database" {
  config_path = "../database"
}

inputs = {

  name         = join("-", [local.app_vars.locals.name,local.instance_vars.locals.name,local.env_vars.locals.name])

  ami                    = "ami-09a56048b08f94cdf"
  instance_type          = "t2.micro"
  key_name               = "ssh-key-pair"   # SSH key-pair needs to be created beforehand
  monitoring             = true
  vpc_security_group_ids = [dependency.ec2-security-group.outputs.security_group_id]
  #subnet_id              = ""

  user_data = <<EOF
#! /bin/bash
sudo apt-get update
echo "Deployed via Terraform!" >> /tmp/this_terraform_file
sudo apt update
sudo apt install install docker docker-compose
cd ~
git clone https://github.com/partha005/python-app.git
echo "MYSQL_DATABASE=example" >> ~/python-app/app/src/.env
echo "MYSQL_ROOT_PASSWORD=test12345" >> ~/python-app/app/src/.env
echo "MYSQL_URL=${dependency.database.outputs.db_instance_address}" >> ~/python-app/app/src/.env
cd python-app; docker-compose up -d
EOF


// provisioner "file" {
//   echo "MYSQL_URL=${dependency.ec2-security-group.outputs.security_group_id}" >> /tmp/envfile
//     content = element(data.template_file.index.[*].rendered, count.index)
//     destination = "~/python-app/app/src/.env"
//   }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }


}
