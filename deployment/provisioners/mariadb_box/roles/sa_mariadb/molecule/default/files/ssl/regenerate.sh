#!/bin/sh

openssl genrsa 2048 > ca-key.pem
# MariaDB admin
openssl req -new -x509 -nodes -days 730 -key ca-key.pem -out ca-cert.pem
# MariaDB server
openssl req -newkey rsa:2048 -days 730 -nodes -keyout server-key.pem -out server-req.pem
openssl rsa -in server-key.pem -out server-key.pem
openssl x509 -req -in server-req.pem -days 730 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem
# MariaDB client
openssl req -newkey rsa:2048 -days 730 -nodes -keyout client-key.pem -out client-req.pem
openssl rsa -in client-key.pem -out client-key.pem
openssl x509 -req -in client-req.pem -days 365000 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 -out client-cert.pem
openssl verify -CAfile ca-cert.pem server-cert.pem client-cert.pem
