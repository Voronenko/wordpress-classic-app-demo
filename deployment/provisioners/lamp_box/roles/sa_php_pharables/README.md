sa-php-pharables
================
[![Build Status](https://travis-ci.org/softasap/sa-php-pharables.svg?branch=master)](https://travis-ci.org/softasap/sa-php-pharables)


Helper role, usually used with sa-php-fpm, optional pre-configured phars like composer or wp,
also possibility to install globally phars of your choice


Example of usage:

Simple

```YAML

vars:
  - my_phars:
      - {
        tool: "composer"
        }
      - {
        tool: "wp"
        }
      - {
        tool: "drush",
        drush_version: "7.4.0"
        }


roles:
     - {
         role: "sa-php-pharables",
         phars: "{{ my_phars }}",
         php_family: "7.0"
       }


```

Advanced

see box-example for full featured lamp install.

```YAML

vars:
  - my_phars:
      - {
        tool: "composer"
        }
      - {
        tool: "wp"
        }
      - {
        tool: "custom",
        phar: "wp-cli.phar",
        url: "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar",
        name: "wp-cli",    
        extra_phar_params: " --require=~/dictator/ "
        }
      - {
        tool: "drush",
        drush_version: "7.4.0"
        }


roles:
     - {
         role: "sa-php-pharables",
         phars: "{{ my_phars }}",
         php_family: default # 5.6 | 7.0 | default
       }


```


Usage with ansible galaxy workflow
----------------------------------

If you installed the `sa-php-pharables` role using the command


`
   ansible-galaxy install softasap.sa-php-pharables
`

the role will be available in the folder `library/softasap.sa-php-pharables`
Please adjust the path accordingly.

```YAML

     - {
         role: "softasap.sa-php-pharables"
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
