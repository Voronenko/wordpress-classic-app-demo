# Static parameters
WORKSPACE=./
BOX_PLAYBOOK=$WORKSPACE/box_sudo.yml
BOX_NAME=sixteen
BOX_ADDRESS=188.166.70.141
BOX_USER=slavko
BOX_PWD=

prudentia ssh <<EOF
unregister $BOX_NAME

register
$BOX_PLAYBOOK
$BOX_NAME
$BOX_ADDRESS
$BOX_USER
$BOX_PWD

verbose 4
set box_address $BOX_ADDRESS
set ansible_become_password secret

provision $BOX_NAME
EOF
