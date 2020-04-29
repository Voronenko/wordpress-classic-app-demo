# One or the possible wordpress development environments

## Creating local VM

Note, that ideally your local machine setup should fully match remote box - it makes a way easier to troubleshoot production issues.
That affects in particular `application_dependencies` parameters as well as php extensions.

Skip this part if you using ESX or some live box.

Vagrant configuration file `deployment/vagrant/vagrant_config.yml`

```sh
vagrant up
```

Important: if you have vagrant configured right, my.wordpress.local will be replaced with vagrant box per

```yaml
vagrant_hostname: my.wordpress.local
vagrant_machine_name: mywordpresslocal
vagrant_ip: 192.168.57.201
```

in other case adjust `www.my.wordpress.local` and `my.wordpress.local` in your /etc/hosts to `192.168.57.201`


## Provisioning box with WP

As you upgrade wordpress from time to time , you need to keep eye on wordpress version on a remote host,
if you deployed and upgraded previously. One of the easy options - to explore `wp-includes/version.php`,
look for `The WordPress version string`.

To provision box `ansible` framework is used. On a project level, hosts are described in `deployment/inventory`,
while loading necessary environment is implemented by sourcing environment from local_ENV.sh files under deployment.

Typical inventory is yaml based and looks like

```yaml
---
all: # keys must be unique, i.e. only one 'hosts' per group
    hosts:
        wordpress:
            ansible_host: 192.168.57.201
            ansible_ssh_user: vagrant
    children:
        base_box:
            hosts:
                wordpress:
        lamp_box:
            hosts:
                wordpress:
        application_box:
            hosts:
                wordpress:
```

Typical flow:

```
./clean_build.sh
source deployment/local_ENV.sh
package.sh
# optional validation using ansible-inventory --list
deployment/pipeline_provision_staging.sh
```


### wp-content-initial

If you start your wordpress setup from previously done sql dump,
you should ensure that wp-content-initial contains all needed custom files
stored under wp-content by various plugins used


### Deploying local development instance based on production one

You need to ensure that `wp-content-initial` corresponds to remote state,
if nope - update.

Copy wp-content-initial to your development instance. Example:

```sh
scp -r wp-content-initial/ vagrant@192.168.57.201:~
```

Copy initial database to your development instance. Example:

```sh
scp -r deployment/initial_db/ vagrant@192.168.57.201:~
```

Now time to import previous data to development instance, as you have "naked wordpress" at a moment.

We do (on a development instance) copy initial wp-content files

```sh
cp -r wp-content-initial/* /var/www/portal/wp-content/
```

You might want to drop all tables in the development wordpress databases (depends what kind of dump do you have)

```sh
mysql -u wordpress -p wordpress

show tables;
```

Warning dropping all tables is a destructive operation, make sure you are on the proper DB!!!

```sql
DROP PROCEDURE IF EXISTS `drop_all_tables`;

DELIMITER $$
CREATE PROCEDURE `drop_all_tables`()
BEGIN
    DECLARE _done INT DEFAULT FALSE;
    DECLARE _tableName VARCHAR(255);
    DECLARE _cursor CURSOR FOR
        SELECT table_name
        FROM information_schema.TABLES
        WHERE table_schema = SCHEMA();
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET _done = TRUE;

    SET FOREIGN_KEY_CHECKS = 0;

    OPEN _cursor;

    REPEAT FETCH _cursor INTO _tableName;

    IF NOT _done THEN
        SET @stmt_sql = CONCAT('DROP TABLE ', _tableName);
        PREPARE stmt1 FROM @stmt_sql;
        EXECUTE stmt1;
        DEALLOCATE PREPARE stmt1;
    END IF;

    UNTIL _done END REPEAT;

    CLOSE _cursor;
    SET FOREIGN_KEY_CHECKS = 1;
END$$

DELIMITER ;

call drop_all_tables();

DROP PROCEDURE IF EXISTS `drop_all_tables`;

show tables;
```

Once you confirmed it is safe to import database - import it

```sh
mysql -u wordpress -p wordpress < initial_db/wp_wordpress.sql
```

After all that could be situation, that you will miss some of the images thumbnails from initial content.
If you do not know exact media ids used by your portal you can use

```sh
seq 1 20000 | xargs wp media regenerate
```

### Changing site url

As per  https://wordpress.org/support/article/changing-the-site-url/

4 methods

method A)

Edit wp-config.php #Edit wp-config.php
It is possible to set the site URL manually in the wp-config.php file.

Add these two lines to your wp-config.php, where “example.com” is the correct location of your site.

```
define( 'WP_HOME', 'http://my.wordpress.local' );
define( 'WP_SITEURL', 'http://my.wordpress.local' );
```
This is not necessarily the best fix, it’s just hard-coding the values into the site itself. You won’t be able to edit them on the General settings page anymore when using this method.

once you reached admin panel - change to proper location there,

method B,C,D) - on URL above


### Unsorted - plugin info

#### Shared plugins

```
acf-google-font-selector-field
better-font-awesome
contact-form-7-honeypot
contact-form-7-multi-step-module
contact-form-7
flamingo
favicon-by-realfavicongenerator
red-olive-marketing
ultimate-member
when-last-login
wordfence
wordpress-importer
wp-html-mail
wp-mail-smtp
wp-postviews
```

#### Custom plugins added to the repo

```
advanced-custom-fields-pro
acf-fonticonpicker
cf7-autosaver
js_composer
pzt-demo-import-wizard
pzt-twitter-feed-widget
soprano-theme-cpts
ultimate_vc
wp-instagram-widget
```



### Magic auto login to wordpress without knowing password

https://gist.github.com/Voronenko/28476c021ff61ae17508d67d06df0d6e



### File permissions

as per  https://wordpress.org/support/article/hardening-wordpress/

Some neat features of WordPress come from allowing various files to be writable by the web server. However, allowing write access to your files is potentially dangerous, particularly in a shared hosting environment.

It is best to lock down your file permissions as much as possible and to loosen those restrictions on the occasions that you need to allow write access, or to create specific folders with less restrictions for the purpose of doing things like uploading files.

Here is one possible permission scheme.

All files should be owned by your user account, and should be writable by you. Any file that needs write access from WordPress should be writable by the web server, if your hosting set up requires it, that may mean those files need to be group-owned by the user account used by the web server process.

`/`

The root WordPress directory: all files should be writable only by your user account, except .htaccess if you want WordPress to automatically generate rewrite rules for you.

`/wp-admin/`

The WordPress administration area: all files should be writable only by your user account.

`/wp-includes/`

The bulk of WordPress application logic: all files should be writable only by your user account.

`/wp-content/`

User-supplied content: intended to be writable by your user account and the web server process.

Within /wp-content/ you will find:

`/wp-content/themes/`

Theme files. If you want to use the built-in theme editor, all files need to be writable by the web server process. If you do not want to use the built-in theme editor, all files can be writable only by your user account.

`/wp-content/plugins/`

Plugin files: all files should be writable only by your user account.

Other directories that may be present with /wp-content/ should be documented by whichever plugin or theme requires them. Permissions may vary.



#### Changing file permissions
If you have shell access to your server, you can change file permissions recursively with the following command:

For Directories:

```sh
find /path/to/your/wordpress/install/ -type d -exec chmod 755 {} \;
```

For Files:

```sh
find /path/to/your/wordpress/install/ -type f -exec chmod 644 {} \;
```

Regarding Automatic Updates #Regarding Automatic Updates

When you tell WordPress to perform an automatic update, all file operations are performed as the user that owns the files,
not as the web server’s user. All files are set to 0644 and all directories are set to 0755, and writable by only the user and readable by everyone else, including the web server.


Specifics of the portal


```php
define( 'WP_HOME', 'http://example.com' );
define( 'WP_SITEURL', 'http://example.com' );
```

```
sudo chmod g+w /var/www/portal/wp-content/wflogs/*.php

sudo chown -R vagrant:www-data /var/www/portal/wp-content/uploads
sudo chmod -R g+w /var/www/portal/wp-content/uploads

```

## Procedure of the manual major production deploy

0. Get developer to push all necessary changes into repository.

That includes

a) database dump in the initia_db
b) corresponding images and related binary content in `wp-content-initial`
c) corresponding changes to private plugins, themes in `wp-content`
d) TESTED portal using local vagrant development environment
e) deployment (list if public plugins, etc) - aligned with the change to the database.

1. Prepare artifact for deploy

```sh
package.sh
````

2. Get to the remote server following files:

a) wp-content-initial

b) deployment artifact `portal-smth.tgz`

c) initial_db


3. On a remote server

a) if needed, make backup of the existing portal and database, just in case

b) Take ownership on existing static content

```
sudo chown -R ubuntu:www-data /var/www/portal/wp-content/
```

c) copy initial binary content

```sh
cp -r wp-content-initial/* /var/www/portal/wp-content/
```

d) Unpack new custom wordpress logic (themes, plugins, etc) - from deployment artifact

```
tar zxvf portal-0.0.1.tgz
cp -r wp-content/* /var/www/portal/wp-content/
```



e) Reset files and permissions according to wordpress security notes above

```sh

find /var/www/portal/wp-content/ -type d -exec chmod 755 {} \;
find /var/www/portal/wp-content/ -type f -exec chmod 644 {} \;

```

by that moment credentials are reset to default one, and write permissions need to be specifically tuned for project purposes

```sh
sudo chmod g+w /var/www/portal/wp-content/wflogs/*.php
sudo chmod -R g+w /var/www/portal/wp-content/uploads

```


f) If database is configured for environment which is different from your side

```sh
nano /var/www/portal/wp-config.php
```

and put

```sh
define( 'WP_HOME', 'https://my.wordpress.local' );
define( 'WP_SITEURL', 'https://my.wordpress.local' );
```

g) Upgrade database

depending on your database dump type you might need to drop tables first

```sh
mysql -u wordpress -p wordpress < initial_db/wp_wordpress.sql
```

h) Regenerate database thumbnails basing on database state

```sh

cd /var/www/portal
seq 1 20000 | xargs wp media regenerate
```

If you will get result kind of

```txt
Success: Regenerated 157 of 159 images (2 skipped).
```

this is good sign - all pictures in the database correspond to filesystem.
If you see errors here - perhaps you missed than on test stage, and your developer did not pass you some information

i) first check

rotate nginx error log, if dirty than

```sh
sudo rm /var/log/nginx/error.log
sudo service nginx restart
sudo tail -f /var/log/nginx/error.lo
```

browse quickly by pages, you should not see any fatal errors in error.log. If you see - find root cause.

j) Login to wp-admin check


## Updating wordpress

Updating wordpress core is done using

```sh
cd /var/www/portal
wp core update
```

Updating wordpress plugins is done using

```sh
wp plugin update PLUGINNAME
```

see list of used plugins in project passport.


