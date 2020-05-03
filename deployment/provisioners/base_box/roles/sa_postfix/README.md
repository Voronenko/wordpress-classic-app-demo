sa-postfix
==========

[![Build Status](https://travis-ci.org/softasap/sa-postfix.svg?branch=master)](https://travis-ci.org/softasap/sa-postfix)


Example of use: check box-example

Simple:

```YAML


     - {
         role: "sa-postfix",
         postfix_hostname: "appserver.example.com"
       }

```


Advanced:

```YAML


     - {
         role: "sa-postfix",
         postfix_hostname: "appserver.example.com",
         postfix_properties:
           - {regexp: "^myhostname =*", line: "myhostname = {{postfix_hostname}}"}
           - {regexp: "^myorigin =*", line: "myorigin = $mydomain"}
           - {regexp: "^relayhost =*", line: "relayhost ="}
           - {regexp: "^inet_interfaces =*", line: "inet_interfaces = loopback-only"}
           - {regexp: "^mydestination =*", line: "mydestination = loopback-only"}
       }

```


# Misc hints

## To check, it actually sends - check

```shell

echo "This is the body of the email" | mail --debug-level 10 -s "This is the subject line" your_email_address

```

And check in /var/log/mail.log. In 2016 with 98% mails will be rejected by +- known mail providers

Note, that by default you have major chances, that sent mail will finish it's line in SPAM.  Configuring your MTA & DNS is out of scope for this role.

## redirect local mail to external email address

```shell
lmtp_host_lookup = native
smtp_host_lookup = native
virtual_alias_maps = hash:/etc/postfix/virtual
```

in /etc/postfix/virtual configure redirection settings:

```
root   youremail@gmail.com
munin  root
```

and apply the settings:

```shell
postmap /etc/postfix/virtual
postfix reload
```

be aware, that _all_ mail for root will be forwarded.

## Rewriting sender domain

in main.cf introduce

```
sender_canonical_maps = hash:/etc/postfix/canonical
```

edit /etc/postfix/canonical to contain smth like
```
root@example.com   no-reply@example.com
@local.example.com       @example.com
```

to apply the settings:
```shell

postmap /etc/postfix/canonical
postfix reload

```


## Filtering emails you want to receive

Once you're satisfied with the content filtering script:

Create a dedicated local user account called "postfixfilter". This user handles all potentially dangerous mail content - that is why it should be a separate account. Do not use "nobody", and most certainly do not use "root" or "postfix".

Create a directory /var/spool/filter that is accessible only to the "postfixfilter" user. This is where the content filtering script is supposed to store its temporary files.

Configure Postfix to deliver mail to the content filter with the pipe delivery agent

/etc/postfix/master.cf:
```
  # =============================================================
  # service type  private unpriv  chroot  wakeup  maxproc command
  #               (yes)   (yes)   (yes)   (never) (100)
  # =============================================================
  filter    unix  -       n       n       -       10      pipe
    flags=Rq user=postfixfilter null_sender=
    argv=/path/to/script -f ${sender} -- ${recipient}
```

Possible options: transfer emails into syslog events or, saying , sentry calls

take a look on example in box-example/templates/content_filter.py.j2


Copyright and license
---------------------

Copyright - Vyacheslav Voronenko

Code licensed under the [BSD 3 clause] (https://opensource.org/licenses/BSD-3-Clause) or the [MIT License] (http://opensource.org/licenses/MIT).

Subscribe for roles updates at [FB] (https://www.facebook.com/SoftAsap/)
