WORKSPACE=$(
  cd $(dirname "$0")
  pwd
)

export INFRASTRUCTURE_ROOT_DIR=${INFRASTRUCTURE_ROOT_DIR:-$WORKSPACE}

export REMOTE_HOST=$INFRASTRUCTURE_ROOT_DIR/provisioners/shared/inventory/vagrant
export ENV_INVENTORY=$INFRASTRUCTURE_ROOT_DIR/provisioners/shared/inventory/vagrant
export ANSIBLE_INVENTORY=$ENV_INVENTORY
export ENVIRONMENT=default
export BOX_PROVIDER=vagrant
