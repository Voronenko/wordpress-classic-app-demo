# Static parameters
WORKSPACE=$PWD
BOX_PLAYBOOK=$WORKSPACE/bootstrap_box.yml
BOX_NAME=lamp_bootstrap
BOX_ADDRESS=192.168.0.27  # .15 -- 16.04
BOX_USER=slavko
BOX_PWD=
ENVIRONMENT=dev

# Register the new Prudentia box, provision it with the staging artifact and eventually unregisters the box
prudentia ssh <<EOF
unregister $BOX_NAME

register
$BOX_PLAYBOOK
$BOX_NAME
$BOX_ADDRESS
$BOX_USER
$BOX_PWD

verbose 4

set env development
set option_force_update true
set app_root /home/slavko/ssq/weddingshoppe/blog

provision $BOX_NAME

unregister $BOX_NAME
EOF
