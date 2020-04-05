sa-nginx
========

[![Build Status](https://travis-ci.org/softasap/sa-nginx.svg?branch=master)](https://travis-ci.org/softasap/sa-nginx)


Basic role for nginx based deployments (like MEAN stack)

Adjusts folder structure to be apache style (i.e. sites-available, sites-enabled)

Adjusts hashbucketsize for longer domains.


Example of usage:

Simple

```YAML

     - {
         role: "sa-nginx"
       }


```

Advanced

```YAML


nginx_add_to_groups:
  - www-data

nginx_conf_properties:
  - {
      regexp: "^daemon *",
      line: "daemon off;",
      insertbefore: "BOF"
    }
  - {
      regexp: "^worker_processes *",
      line: "worker_processes auto;",
      insertbefore: "BOF"
    }
  - {
      regexp: "^pid *",
      line: "pid {{nginx_pid_dir}}/nginx.pid;",
      insertbefore: "BOF"
    }

  - {
      role: "sa-nginx",
      nginx_conf_properties: "{{nginx_conf_properties}}",
      nginx_groups: "{{nginx_add_to_groups}}"
    }


```



Usage with ansible galaxy workflow
----------------------------------

If you installed the `sa-nginx` role using the command


`
   ansible-galaxy install softasap.sa-nginx
`

the role will be available in the folder `library/softasap.sa-nginx`
Please adjust the path accordingly.

```YAML

     - {
         role: "softasap.sa-nginx"
       }

```

requirements.yml snippet:

```YAML
- src: softasap.sa-nginx
  name: sa-nginx
```



Copyright and license
---------------------

Code is dual licensed under the [BSD 3 clause] (https://opensource.org/licenses/BSD-3-Clause) and the [MIT License] (http://opensource.org/licenses/MIT). Choose the one that suits you best.

Reach us:

Subscribe for roles updates at [FB] (https://www.facebook.com/SoftAsap/)

Join gitter discussion channel at [Gitter](https://gitter.im/softasap)

Discover other roles at  http://www.softasap.com/roles/registry_generated.html

visit our blog at http://www.softasap.com/blog/archive.html 
