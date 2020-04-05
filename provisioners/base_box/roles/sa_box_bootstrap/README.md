
[![Build Status](https://travis-ci.org/softasap/sa-box-bootstrap.svg?branch=master)](https://travis-ci.org/softasap/sa-box-bootstrap)


Example of usage:

Simple

```YAML

  roles:
     - {
         role: "sa-box-bootstrap",
         deploy_user: "{{jenkins_user}}",
         deploy_user_authorized_keys: "{{jenkins_authorized_keys}}",
         timezone: "Europe/Kiev"
       }


```

Advanced

```YAML

  vars:
    - root_dir: ..

    - jenkins_user: jenkins
      jenkins_authorized_keys:
        - "{{playbook_dir}}/components/files/ssh/vyacheslav1.pub"
        - "{{playbook_dir}}/components/files/ssh/vyacheslav2.pub"
        - "{{playbook_dir}}/components/files/ssh/vyacheslav3.pub"
        - "{{playbook_dir}}/components/files/ssh/vyacheslav4.pub"
    - timezone: "Europe/Kiev"

  pre_tasks:
    - debug: msg="Pre tasks section"

  roles:
     - {
         role: "sa-box-bootstrap",
         deploy_user: "{{jenkins_user}}",
         deploy_user_key: "{{playbook_dir}}/components/files/ssh/jenkins_rsa",
         deploy_user_pub_key: "{{playbook_dir}}/components/files/ssh/jenkins_rsa.pub",
         deploy_user_authorized_keys: "{{jenkins_authorized_keys}}",

         timezone: "Europe/Kiev",

         option_copy_initial_authorized_keys: true,
         option_enforce_ssh_keys_login: true,
         option_file2ban: true,
         option_firewall: true,
         option_monit: true

       }

```

Important: if you would not specify `deploy_user_sudo_password` parameter, the created deployment user will be allowed to execute sudo w/o password confirmation.
While in some cases it is ok, having additional level of security is never bad, thus:


Deployment user requesting a sudo password

```YAML

  vars:
    - user_authorized_keys:
        - "~/.ssh/id_rsa.pub"
    - user_sudo_pass: "secret"

  roles:
     - {
         role: "sa-box-bootstrap",
         deploy_user: "slavko",
         deploy_user_authorized_keys: "{{user_authorized_keys}}",
         deploy_user_sudo_password: "{{user_sudo_pass | password_hash('sha512')}}",
         option_enforce_ssh_keys_login: yes
       }

```

If you have deployment user which requires entering sudo password, you need to provide it via `ansible_become_password` parameter.

```

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


```


Prepare your box for deployment
=======================================

# Background

Nowadays deployments moved from bare metal servers to a quickly started virtual machines,
like the one provided by Amazon, Digital Ocean, OpenStack based providers.
Thus no longer configuration of the box requires manual administration steps.
One of the options is ready to use pre-configured box images.  Another approach is to
start from initial system restart and provision it according to project needs with some provisioner like
Ansible, Chef or Puppet.

The first step to proceed with custom provisioning - is to perform basic box securing,
as in some cases you are given with freshly installed box with the root password.s

Let me share with you quick recipe on initial box securing , which should be good for most of web deployments.

## Challenges to address
  At the end of the article we should be able secure  ubuntu 14.04 LTS virtual server

- configure firewall, allow only 22, 443 and 80 in.
- register your public key(s) for deploy user
- secure ssh to allow only authorization by keys.
- put automatic process in play to ban open ssh port lovers from the  internet.

# Bootstrap box role
Ansible comes with a nice concept of reusing deployment snippets, called roles. So let's take a look,
what *sa-box-bootstrap* role does:

## Configuration options
Following variables might be overwritten:
- root_dir  - required, [Ansible developer recipes](https://github.com/Voronenko/ansible-developer_recipes) repository
- option_enforce_ssh_keys_login (true|false) - whenever to enforce ssh security
- ufw_rules_default - default firewall policy. In most cases is not touched
- ufw_rules_allow - set of inbound rules to be configured
- sshd_config_lines - needed changes in SSHD config to secure the box.
- option_file2ban - when true, file2ban package will additionally introduced
- whitelistedips - set of ips that are considered safe - your office gateway, build server etc; To prevent you being accidentaly blocked

## Step 1 : Put firewall on
1-st step install and configure ufw firewall:
```YAML
- include: "{{root_dir}}/tasks_ufw.yml"
```
by default, following firewall rules apply (outgoing any, http https & ssh are allowed inside):
```YAML
ufw_rules_default:
  - {
      policy: deny,
      direction: incoming
    }
  - {
      policy: allow,
      direction: outgoing
    }

ufw_rules_allow:
  - {
      port: 80,
      proto: tcp
     }
  - {
      port: 443,
      proto: tcp
    }
  - {
      port: 22,
      proto: tcp
     }
```
You can override these variables to match your needs.

## Step 2: Create deploy user
If you intend to work & provision this box, most likely you don't want to do it under the root.
Thus, second step is - create deploy user, authorized by set of provided ssh keys, allowed to become sudoer w/o password (base requirement for automated provisioning)
```YAML
- include: "{{root_dir}}/use/__create_deploy_user.yml user={{deploy_user}} group={{deploy_user}} home=/home/{{deploy_user}}"
  when: deploy_user is defined

- name: SSH | Authorize keys
  authorized_key: user={{deploy_user}} key="{{ lookup('file', item) }}"
  when: deploy_user_keys is defined
  with_items: "{{deploy_user_keys}}"
  sudo: yes
```

You might define the user in your playbook, for example, in this way:
```YAML
jenkins_user: jenkins
jenkins_authorized_keys:
  - "{{playbook_dir}}/components/files/ssh/vyacheslav.pub"
```

and later pass this as a parameters to role:
```YAML
roles:
   - {
       role: "sa-box-bootstrap",
       root_dir: "{{playbook_dir}}/public/ansible_developer_recipes",
       deploy_user: "{{jenkins_user}}",
       deploy_user_keys: "{{jenkins_authorized_keys}}"
     }
```

## Step 3: Secure SSH (optional)
```YAML
- name: SSH | Enforce SSH keys security
  lineinfile: dest=/etc/ssh/sshd_config regexp="{{item.regexp}}" line="{{item.line}}"
  with_items: "{{sshd_config_lines}}"
  when: option_enforce_ssh_keys_login
  become: yes
  tags: ssh
```

If var *option_enforce_ssh_keys_login* is set to true, sshd config is modified according to
sshd_config_lines rules.  By default, it is using v2 protocol, prohibiting root login,
prohibiting password authenticaton.

## Step 4: Ban strange persons guessing your ssh user access
If var option_file2ban is set to true. Special tool file2ban is installed.
It will watch out for failure ssh logging attempts and ban out intruders.
To prevent yourself from being accidentally blocked, good idea to whitelist your ips, both single IPs and network masks are supported, for example:
```YAML
whitelistedips:
 - 127.0.0.1
 - 127.0.0.1/8
```

# Creating your own box bootstrap project

Let's prepare basic bootstrap project, that can be used in the future.
It includes following files:

- *bootstrap.sh* - installs ansible alongside with dependences.
- *init.sh* - initializes
- *.projmodules* - fully compatible with .gitmodules git syntax,  specifies list of the dependencies
that will be used by the playbook.
In particular, it includes ansible- by default developer_recipes (repository with set of handy deployment recipes)
and ansible role called  *sa-box-bootstrap* responsible for box securing steps.

```
[submodule "public/ansible_developer_recipes"]
	path = public/ansible_developer_recipes
	url = git@github.com:Voronenko/ansible-developer_recipes.git
[submodule "roles/sa-box-bootstrap"]
        path = roles/sa-box-bootstrap
        url = git@github.com:softasap/sa-box-bootstrap.git
```
- *hosts* - list here the initial box credentials, that were provided to you for the server
```
[bootstrap]
box_bootstrap ansible_ssh_host=192.168.0.17 ansible_ssh_user=your_user ansible_ssh_pass=your_password
```
- *box_vars.yml* - set here specific environment overrides, like your preffered deploy user name and keys.
- *box_bootstrap.yml* - here you put your box provisioning steps. Box securing is only the first step.
In order, to override params for *sa-box-bootstrap* - pass the parameters like in example below.

```YAML

- hosts: all

  vars_files:
    - ./box_vars.yml
  roles:
     - {
         role: "sa-box-bootstrap",
         root_dir: "{{playbook_dir}}/public/ansible_developer_recipes",
         deploy_user: "{{my_deploy_user}}",
         deploy_user_keys: "{{my_deploy_authorized_keys}}"
       }

```





# Code in action

Code can be downloaded from repository [https://github.com/Voronenko/devops-bootstrap-box-template](https://github.com/Voronenko/devops-bootstrap-box-template)
In order to use it - fork it, adjust parameters to your needs, and use.
Adjusting includes: creation of box_vars.yml file. You can override there any of mentioned above variables.
The minimal required set is deploy_user and your public keys.

```
box_deploy_user: jenkins
box_deploy_authorized_keys:
  - "{{playbook_dir}}/components/files/ssh/vyacheslav.pub"
```

Ensure, you have ansible (bootstrap.sh to install) and cloned roles directories (init.sh)
Than run setup.sh.  If everything is configured correctly, you will see smth like that:
```
PLAY [all] ********************************************************************

GATHERING FACTS ***************************************************************
ok: [box_bootstrap]

TASK: [sa-box-bootstrap | Sets correctly hostname] ****************************
changed: [box_bootstrap]

TASK: [sa-box-bootstrap | debug var="ufw_rules_allow"] ************************
ok: [box_bootstrap] => {
    "var": {
        "ufw_rules_allow": [
            {
                "port": 80,
                "proto": "tcp"
            },
            {
                "port": 443,
                "proto": "tcp"
            },
            {
                "port": 22,
                "proto": "tcp"
            }
        ]
    }
}

TASK: [sa-box-bootstrap | UFW | Reset it] *************************************
ok: [box_bootstrap]

TASK: [sa-box-bootstrap | UFW | Configure incoming/outgoing defaults] *********
ok: [box_bootstrap] => (item={'policy': 'deny', 'direction': 'incoming'})
ok: [box_bootstrap] => (item={'policy': 'allow', 'direction': 'outgoing'})

TASK: [sa-box-bootstrap | UFW | Configure rules to allow incoming traffic] ****
ok: [box_bootstrap] => (item={'port': 80, 'proto': 'tcp'})
ok: [box_bootstrap] => (item={'port': 443, 'proto': 'tcp'})
ok: [box_bootstrap] => (item={'port': 22, 'proto': 'tcp'})

TASK: [sa-box-bootstrap | UFW | Configure rules to allow incoming traffic from specific hosts] ***
skipping: [box_bootstrap] => (item=ufw_rules_allow_from_hosts)

TASK: [sa-box-bootstrap | UFW | Enable it] ************************************
changed: [box_bootstrap]

TASK: [sa-box-bootstrap | Monit | Check if is installed] **********************
changed: [box_bootstrap]

TASK: [sa-box-bootstrap | Monit | libssl-dev dependency] **********************
changed: [box_bootstrap]

TASK: [sa-box-bootstrap | Monit | Download] ***********************************
changed: [box_bootstrap]

TASK: [sa-box-bootstrap | Monit | Install] ************************************
changed: [box_bootstrap]

TASK: [sa-box-bootstrap | debug msg="Creating deploy user {{my_deploy_user}}:{{my_deploy_user}} with home directory /home/{{my_deploy_user}}"] ***
ok: [box_bootstrap] => {
    "msg": "Creating deploy user jenkins:jenkins with home directory /home/jenkins"
}

TASK: [sa-box-bootstrap | Deploy User | Creating group] ***********************
changed: [box_bootstrap]

TASK: [sa-box-bootstrap | Deploy User | Creating user] ************************
changed: [box_bootstrap]

TASK: [sa-box-bootstrap | Deploy User | Check key presence] *******************
ok: [box_bootstrap]

TASK: [sa-box-bootstrap | Deploy User | Copy authorized_keys from {{ansible_user_id}}] ***
skipping: [box_bootstrap]

TASK: [sa-box-bootstrap | Deploy User | Set permission on authorized_keys] ****
skipping: [box_bootstrap]

TASK: [sa-box-bootstrap | Deploy User | Ensuring sudoers no pwd prompting] ****
changed: [box_bootstrap]

TASK: [sa-box-bootstrap | SSH | Authorize keys] *******************************
changed: [box_bootstrap] => (item=/home/slavko/labs/devops-bootstrap-box-template/components/files/ssh/vyacheslav.pub)

TASK: [sa-box-bootstrap | SSH | Enforce SSH keys security] ********************
ok: [box_bootstrap] => (item={'regexp': '^Protocol.*', 'line': 'Protocol 2'})
changed: [box_bootstrap] => (item={'regexp': '^PermitRootLogin.*', 'line': 'PermitRootLogin no'})
ok: [box_bootstrap] => (item={'regexp': '^RSAAuthentication.*', 'line': 'RSAAuthentication yes'})
ok: [box_bootstrap] => (item={'regexp': '^PubkeyAuthentication.*', 'line': 'PubkeyAuthentication yes'})
ok: [box_bootstrap] => (item={'regexp': '^ChallengeResponseAuthentication.*', 'line': 'ChallengeResponseAuthentication no'})
changed: [box_bootstrap] => (item={'regexp': '^PasswordAuthentication.*', 'line': 'PasswordAuthentication no'})
changed: [box_bootstrap] => (item={'regexp': '^MaxAuthTries.*', 'line': 'MaxAuthTries 3'})

TASK: [sa-box-bootstrap | SSH | Restart SSHD] *********************************
changed: [box_bootstrap]

TASK: [sa-box-bootstrap | Install base Ubuntu packages] ***********************
changed: [box_bootstrap] => (item=unzip,mc)

PLAY RECAP ********************************************************************
box_bootstrap              : ok=21   changed=13   unreachable=0    failed=0   
```

Finally - you have the secured box, with the sudoer - deployed user you specified,
allowed to authorize only with keys you set. Root is not allowed to login. Only
some inbound ports are allowed according to your rules.

Check with NMap and try to login:
```shell

ssh  192.168.0.17
Permission denied (publickey).

ssh -ldeploy_user 192.168.0.17
Welcome to Ubuntu 14.04.2 LTS (GNU/Linux 3.13.0-32-generic x86_64)
deploy_user@LABBOX17:~$

```

# Points of interest

You can reuse this playbook to create your own box bootstaping projects, and
reuse the role to configure your environments quicker in secure way with ansible
