init-terraform:
	cd providers/ovh && terraform init
init-provisioners:
	cd provisioners/app-box && ./init_galaxy.sh --force || true
	cd provisioners/base-box && ./init_galaxy.sh --force || true
	cd provisioners/lamp-box && ./init_galaxy.sh --force || true
	cd provisioners/mysql-box && ./init_galaxy.sh --force || true

show-bb-keys:
	@curl -X GET -H 'Content-Type: application/json' -H 'Authorization: Bearer $(DIGITALOCEAN_TOKEN)' "https://api.digitalocean.com/v2/account/keys" | jq

show-ovh-keys:
	@nova keypair-list

show-ovh-keys-via-token:
	@nova --os-token $(OS_TOKEN) keypair-list
