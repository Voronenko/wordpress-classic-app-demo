get-cli:
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
init-wordpress:
	php wp-cli.phar core download
rename-local-artifact:
	mv wordpress-deployment-*.tgz wordpress-0.0.1.tgz
copy-local-db:
	scp -r deployment/initial_db vagrant@192.168.57.201:~
	echo use
	echo "mysql -u wordpress -p wordpress < initial_db/wp_initial.sql"
copy-wpcontent-initial:
	scp -r wp-content-initial/ vagrant@192.168.57.201:~
	echo use on host
	echo  "cp -r wp-content-initial/* /var/www/wordpress/wp-content/"
copy-local-prod:
	scp -r deployment/initial_db ubuntu@yourdomain.com:~
	scp wordpress*.tgz ubuntu@yourdomain.com:~
	echo use
	echo "mysql -u wordpress -p wordpress < initial_db/wp_wordpress.sql"
copy-wpcontent-initial-prod:
	scp -r wp-content-initial/ ubuntu@yourdomain.com:~
	echo use on host
	echo  "cp -r wp-content-initial/* /var/www/wordpress/wp-content/"

