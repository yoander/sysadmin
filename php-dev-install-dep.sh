#/usr/bin/env bash
PKG_MNGR=$(which yum || which apt-get) 

[[ '' == $PKG_MNGR ]] && {
    echo This is script is intended for Debian GNU/Linux or CentOS base family distro.\
        If you are using another GNU/Linux distribution then you need to adjust the script\
        by yourself. Thanks!
    exit 1
}

CMD=

if [[ 'root' != $(whoami) ]]; then
    CMD=$(which sudo)
    [[ '' == $CMD ]] && { echo You need sudo tool for installing php development dependencies!!!; exit 1; }
fi

$CMD $PKG_MNGR -y install make autoconf gcc libxml2-dev libssl-dev openssl \
         libpcre3-dev libsqlite3-dev libbz2-dev libcurl4-openssl-dev libgd2-xpm-dev \
         libicu-dev libmcrypt-dev libpq-dev libreadline-dev apache2  apache2-mpm-prefork \
         apache2-prefork-dev bison flex re2c libtool

echo "Done!!!"
