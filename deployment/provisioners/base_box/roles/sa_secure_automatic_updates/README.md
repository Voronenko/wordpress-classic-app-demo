sa-secure-automatic-updates
===========================

[![Build Status](https://travis-ci.org/softasap/sa-secure-automatic-updates.svg?branch=master)](https://travis-ci.org/softasap/sa-secure-automatic-updates)


Forces automatic installation of the security updates on Ubuntu LTS servers



Example of use:
```YAML

     - {
         role: "sa-secure-automatic-updates"
       }

```

Advanced:
```YAML
     - {
         role: "sa-secure-automatic-updates",
         unattended_origins_patterns: [ '${distro_id}:${distro_codename}-security' ],
         unattended_package_blacklist: [],
         unattended_properties_extra:
          - {regexp: "^(\/\/)? Unattended-Upgrade::SyslogEnable *", line:"Unattended-Upgrade::SyslogEnable"},
         unattended_allow_reboot_time: "01:00"
       }
```

See box-example for standalone installation example


Usage with ansible galaxy workflow
----------------------------------

If you installed the sa-secure-automatic-updates role using the command


`
   ansible galaxy install softasap.sa-secure-automatic-updates
`

the role will be available in the folder library\softasap.sa-secure-automatic-updates.
Please adjust the path accordingly.

```YAML

     - {
         role: "softasap.sa-secure-automatic-updates"
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
