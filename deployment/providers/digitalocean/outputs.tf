
locals {

  environment_yml = <<YAML

# terraform managed
# This file was generated by terraform for workspace ${terraform.workspace}

option_enforce_ssh_keys_login: true
option_ufw: true
box_deploy_user: ubuntu

YAML


  envvars = <<ENVVARS
export REMOTE_HOST=$INFRASTRUCTURE_ROOT_DIR/provisioners/shared/inventory/${local.env}
export ENV_INVENTORY=$INFRASTRUCTURE_ROOT_DIR/provisioners/shared/inventory/${local.env}
export ANSIBLE_INVENTORY=$ENV_INVENTORY
export REMOTE_USER_INITIAL=ubuntu
export REMOTE_PASSWORD_INITIAL=
export BOX_DEPLOY_USER=ubuntu
export ENVIRONMENT=${local.env}
export PROVIDER=digitalocean
# if you use sudo
export BOX_DEPLOY_PASS=
#export ANSIBLE_VAULT_IDENTITY=@$HOME/PASSHERE/vault_pass.txt

echo # first import envvars if needed ...
echo cd $INFRASTRUCTURE_ROOT_DIR/provisioners/app-test
echo ./p_aws.sh


ENVVARS

  inventory_digitalocean = <<INVENTORYDO
[web]
${digitalocean_droplet.web.ipv4_address} ansible_connection=ssh ansible_ssh_user=ubuntu ansible_ssh_pass=

INVENTORYDO


  help = <<HELP
terraform output environment_yml
terraform output envvars
terraform output inventory_digitalocean
HELP
}

# ######################################################

output "help" {
  value="${local.help}"
}


resource "local_file" "shared_provider_vars" {
  content     = "${local.environment_yml}"
  filename = "${path.root}/../../provisioners/shared/providers/digitalocean-${local.env}-vars.yml"
}

resource "local_file" "shared_inventory" {
  content     = "${local.inventory_digitalocean}"
  filename = "${path.root}/../../provisioners/shared/inventory/${local.env}/inventory"
}

resource "local_file" "shared_envvars" {
  content     = "${local.envvars}"
  filename = "${path.root}/../../local_${local.env}.sh"
}