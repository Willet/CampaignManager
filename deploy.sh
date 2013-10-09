#!/bin/sh

# (either) sudo apt-get install s3cmd
# (or)             brew install s3cmd
# s3cmd --configure
# New settings:
#   Access Key: ...
#   Secret Key: ...
#   Encryption password: do not enter one
#   Path to GPG program: /usr/bin/gpg
#   Use HTTPS protocol: False
#   HTTP Proxy server name:
#   HTTP Proxy server port: 0

print_msg () {
    local BLUE="\033[1;36m";
    local NO_COLOUR="\033[0m";
    echo $BLUE $1 $NO_COLOUR;
}

# require parameter 1
if [ "$1" = "" ]; then
    print_msg "Usage: $0 <bucket name, e.g. campaign-manager-test> <secret key>" && exit 1
fi

# require s3cmd to be configured
if [ ! -f ~/.s3cfg ]; then
    print_msg "Configure s3cmd first using: s3cmd --configure" && exit 1
fi

print_msg  "Building project..."

grunt build || (print_msg "Build failed" && exit 1)

print_msg  "Uploading project..."

s3cmd sync —exclude ./dist/ s3://$1.secondfunnel.com/ || (print_msg "Sync failed" && exit 1)

print_msg  "Correcting project permissions..."

s3cmd setacl --acl-public --recursive s3://$1.secondfunnel.com/ || (print_msg "Permission thingy failed" && exit 1)

print_msg  "Done!"