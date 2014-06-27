#!/usr/bin/env bash

DIR="$(cd "$(dirname "$0" )" && pwd )"
WEB_USR=www-data
WEB_GROUP=www-data
PREFIX=/usr
PHP_CONF=

[[ $# -lt 1 ]] && { echo -e 'Wrong number of args type -h for help.'; exit 1; }

while getopts ':andcfp:' OPTION; do
    case $OPTION in
    a) # Apache support
        PHP_CONF=" $PHP_CONF --with-apxs2=$(which apxs2)"
	;;
    c) # Fast CGI support
        PHP_CONF=" $PHP_CONF --enable-fpm --with-fpm-user=$WEB_USR --with-fpm-group=$WEB_GROUP "
        ;;
    d) # Enable Debug
        PHP_CONF=" $PHP_CONF --enable-debug --enable-maintainer-zts " 
        ;;
    n) # Disable debug
        PHP_CONF=" $PHP_CONF --disable-debug"
        ;;
    f) # Enable ftp extension
        PHP_CONF="$PHP_CONF --enable-ftp"
        ;;
    p) # Install prefix
        PREFIX=$OPTARG
        ;;
    e) # Enable extra options
        PHP_CONF=" $PHP_CONF
            --enable-exif \
            --enable-calendar \
            --with-snmp=/usr \ 
            --with-pspell \
            --with-tidy=/usr \
            --with-xmlrpc \
            --with-xsl=/usr \
    ";;
    ?) # Help 
        echo -e "Usage: build \033[33msource_dir\033[0m \033[32m[options]\033[0m"
        echo -e "  Arguments:"
        echo -e "    \033[33msource_dir\033[0m     php source directory, example: '~/php/php-5.4'"
        echo -e "  Options:"
        echo -e "    \033[32m-a\033[0m        build with apache support"
        echo -e "    \033[32m-c\033[0m        build with fastcgi support"
        echo -e "    \033[32m-d\033[0m        build with debug enabled"
        echo -e "    \033[32m-e\033[0m        Enable extra options"
        echo -e "    \033[32m-f\033[0m        build with ftp support"
        echo -e "    \033[32m-n\033[0m        build with debug disabled"
        echo -e "    \033[32m-p\033[0m        Install DIR prefix"
        echo -e "\n  When finished, run make install afterwards, or make test first"
        ;;
    esac
done
shift $(($OPTIND - 1))

[[ ! -d "$1" ]]&& { echo Php source is not valid directory; exit 2; }

if [[ "$PREFIX" =~ ^/usr/local/?$ ]]; then 
    SYSCONFDIR=$PREFIX/etc/php 
elif [[ "$PREFIX" =~ ^/usr/?$ ]]; then 
    SYSCONFDIR=/etc/php
else
    echo -e "Invalid install dir: $PREFIX"
fi

PHP_CONF="--config-cache \
    --prefix=$PREFIX \
    --sbindir=$PREFIX/bin \
    --sysconfdir=$SYSCONFDIR \
    --localstatedir=/var \
    --with-layout=GNU \
    --with-config-file-path=$SYSCONFDIR \
    --with-config-file-scan-dir=$SYSCONFDIR/conf.d \
    --disable-rpath \
    --mandir=$PREFIX/share/man \
    $PHP_CONF
"

EXTENSION_DIR=$PREFIX/lib/php/modules
export EXTENSION_DIR
PEAR_INSTALLDIR=$PREFIX/share/pear
export PEAR_INSTALLDIR
# new icu libs for intl does not include this stdc++ lib ld flag
EXTRA_LIBS=-lstdc++
export EXTRA_LIBS

[[ ! -d "$SYSCONFDIR" ]] && { echo -e "You must create config dirs: $SYSCONFDIR, $SYSCONFDIR/conf.d!"; echo -e Bye!!!; exit 3; } 

[[ ! -d "$EXTENSION_DIR" ]] && { echo -e "You must create extension dir: $EXTENSION_DIR!"; echo -e Bye!!!; exit 4; }

[[ ! -d "$PEAR_INSTALLDIR" ]]&& { echo -e "You must create PEAR dir: $PEAR_INSTALLDIR!"; echo -e Bye!!!; exit 5; }

EXT_CONF="--enable-mbstring \
    --enable-mbregex \
    --enable-phar \
    --enable-posix \
    --enable-soap \
    --enable-sockets \
    --enable-sysvmsg \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-zip \
    --enable-inline-optimization \
    --enable-intl \
    --with-icu-dir=/usr \
    --with-curl=/usr/bin \
    --with-gd \
    --with-jpeg-dir=/usr \
    --with-png-dir=shared,/usr \
    --with-freetype-dir=/usr \
    --with-bz2 \
    --with-gettext \
    --with-iconv-dir=/usr \
    --with-mcrypt=/usr \
    --with-mhash \
    --with-zlib-dir=/usr \
    --with-xpm-dir=/usr \
    --with-regex=php \
    --with-pcre-regex=/usr \
    --with-openssl \
    --with-openssl-dir=/usr/bin \
    --with-mysql-sock=/var/run/mysqld/mysqld.sock \
    --with-mysqli=mysqlnd \
    --with-pdo-pgsql=/usr \
    --with-sqlite3=/usr \
    --with-pdo-mysql=mysqlnd \
    --with-pdo-pgsql=/usr \
    --with-pdo-sqlite=/usr
"

if [[ "$1" =~ [[:digit:]]+(\.[[:digit:]]+)? ]]; then
    [[ ${BASH_REMATCH} > 5 ]] && PHP_CONF="$PHP_CONF --enable-opcache "
fi

cd "$1"

if [ ! -f "$DIR/configure" ]; then
    ./buildconf --force # build configure, not included in git versions
fi

./configure ${PHP_CONF} \
    --disable-cgi \
    --with-readline \
    --enable-pcntl \
    --enable-cli \
    --with-pear \
    ${EXT_CONF}

make
