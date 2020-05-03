sa-mariadb
==========

[![Build Status](https://travis-ci.org/softasap/sa-mariadb.svg?branch=master)](https://travis-ci.org/softasap/sa-mariadb)

MariaDB is dropin replacement for mysql with own features

Example of usage (all parameters are optional)

Simple

```
  roles:
    - {
        role: "sa-mariadb"
      }
```

Advanced:

```
  roles:
    - {
        role: "sa-mariadb",
        mariadb_family: "10.1",
        mariadb_bind_to: 127.0.0.1,

        mysql_host: "127.0.0.1",
        mysql_root_user: root,
        mysql_root_password: caspiwrocl,

        # For installation in VPC we really don't have brute force attacks
        mycnf_extra_properties:
           - {regexp: "^#* *max_connect_errors", line: "max_connect_errors = 4294967295", insertafter: '\[mysqld\]'}        
      }
```




Note: if you ever needed to downgrade mysql on xenial to 5.6 rather than default 5.7 available now - use this replacement role `sa-mysql56`:

https://github.com/softasap/sa-mysql56


Usage with ansible galaxy workflow
----------------------------------

If you installed the sa-mariadb role using the command


`
   ansible-galaxy install softasap.sa-mariadb
`

the role will be available in the folder library/softasap.sa-mariadb
Please adjust the path accordingly.

```YAML

     - {
         role: "softasap.sa-mariadb"
       }

```

requirements.yml snippet: 

```YAML
- src: softasap.sa-mariadb
  name: sa-mariadb
```




Copyright and license
---------------------

Code is dual licensed under the [BSD 3 clause] (https://opensource.org/licenses/BSD-3-Clause) and the [MIT License] (http://opensource.org/licenses/MIT). Choose the one that suits you best.

Reach us:

Subscribe for roles updates at [FB] (https://www.facebook.com/SoftAsap/)

Join gitter discussion channel at [Gitter](https://gitter.im/softasap)

Discover other roles at  http://www.softasap.com/roles/registry_generated.html

visit our blog at http://www.softasap.com/blog/archive.html


