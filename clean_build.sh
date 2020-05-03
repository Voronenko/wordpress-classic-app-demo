 #!/bin/bash

PHP=${PHP_VERSION-php7.3}
DEPLOYABLES="wp-content"

mkdir -p ./build

for item in $DEPLOYABLES; do cp -r "$item" build; done
