sa-apache
==========

[![Build Status](https://travis-ci.org/softasap/sa-apache.svg?branch=master)](https://travis-ci.org/softasap/sa-apache)

This role is used in conjunction with other roles, that require apache installed itself.

Example of usage (all parameters are optional)

Simple

```yaml

  roles:
    - {
        role: "sa-apache"
      }
```


Advanced:


```yaml
  roles:
    - {
        role: "sa-apache",
        apache_mode: "worker", # prefork | worker
        apache2_disable_default: true,
        apache_modules:
          - rewrite
          - ssl
      }
```



Usage with ansible galaxy workflow
----------------------------------

If you installed the `sa-apache` role using the command


`
   ansible-galaxy install softasap.sa-apache
`

the role will be available in the folder `library/softasap.sa-apache`
Please adjust the path accordingly.

```YAML

     - {
         role: "softasap.sa-apache"
       }

```


Copyright and license
---------------------

Code is dual licensed under the [BSD 3 clause] (https://opensource.org/licenses/BSD-3-Clause) and the [MIT License] (http://opensource.org/licenses/MIT). Choose the one that suits you best.

Reach us:

Subscribe for roles updates at [FB] (https://www.facebook.com/SoftAsap/)

Join gitter discussion channel at [Gitter](https://gitter.im/softasap)

Discover other roles at  http://www.softasap.com/roles/registry_generated.html

visit our blog at http://www.softasap.com/blog/archive.html

