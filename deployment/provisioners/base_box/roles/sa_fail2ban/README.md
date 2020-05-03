sa-file2ban
============
[![Build Status](https://travis-ci.org/softasap/sa-file2ban.svg?branch=master)](https://travis-ci.org/softasap/sa-file2ban)



Fail2ban scans log files (e.g. /var/log/apache/error_log) and bans IPs that show the malicious signs -- too many password failures, seeking for exploits, etc. Generally Fail2Ban is then used to update firewall rules to reject the IP addresses for a specified amount of time, although any arbitrary other action (e.g. sending an email) could also be configured. Out of the box Fail2Ban comes with filters for various services (apache, courier, ssh, etc).
Fail2Ban is able to reduce the rate of incorrect authentications attempts however it cannot eliminate the risk that weak authentication presents. Configure services to use only two factor or public/private authentication mechanisms if you really want to protect services.


Example of use: check box-example

Simple:

```YAML


     - {
         role: "sa-fileban"
       }

```


Advanced:

```YAML

my_file2ban_action: "hostsdeny[file=/etc/hosts.deny]"  # ufw
my_file2ban_ban_time: 900 # 15 min per SMIG recommendations

my_file2ban_jaillocal_template: "{{playbook_dir}}/templates/fail2ban.jail.local.j2"

my_whitelisted_boxes:
  - "sshd:	192.168.0.10"
  - "sshd:	192.168.0."
  - "sshd:	192.168.0.0/255.255.255.0"

```


```YAML


     - {
         role: "sa-file2ban",
         file2ban_action: "ufw",
         file2ban_ban_time: 900
       }

```



If you have some own jail.local plans that need to target more than just default sshd, you may
pass it as `file2ban_jaillocal_template` or completely skip by setting to False

```YAML


     - {
         role: "sa-file2ban",
         file2ban_jaillocal_template: "{{playbook_dir}}/templates/fail2ban.jail.local.j2"
       }

```



If you have chosen to use hosts.deny, you may want too whitelist your known control hosts

```YAML


     - {
         role: "sa-file2ban",
         file2ban_whitelisted_hosts: "{{my_whitelisted_boxes}}"
       }

```


Copyright and license
---------------------


Code licensed under the [BSD 3 clause] (https://opensource.org/licenses/BSD-3-Clause) or the [MIT License] (http://opensource.org/licenses/MIT).

Subscribe for roles updates at [FB] (https://www.facebook.com/SoftAsap/)
