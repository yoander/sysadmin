#!/usr/bin/env bash
# GNU shell script to compile PHP 
# --------------------------------------------------------------------
# Copyleft 2014 Yoander Valdés Rodríguez <http://www.librebyte.net/>
# This script is inspired by:
# <http://github.com/l3pp4rd/dotfiles/blob/master/build/php/build.sh/> 
# and released under GNU GPL 2+ licence  
# --------------------------------------------------------------------
# It's intended to use as helper for PHP compilation process.
# Enable the most used extensions as: curl, openssl, intl, mysql,
# pcre, ... and allows to install PHP in custom dir, offers options 
# to compile PHP with Apache (prefork or worker) or fpm support.
# --------------------------------------------------------------------
#
DIR="$(cd "$(dirname "$0" )" && pwd )"
WEB_USR=www-data
WEB_GROUP=www-data
# Install prefix
PREFIX=/usr
MAIN_CONF=

[[ "$@" =~ \-a.*(\-?f) ]] && { echo a and ${BASH_REMATCH[1]} are exclusive options; exit 11; }

(($# == 0)) && { echo -e 'Wrong number of args type -h for help.'; exit 1; }

while getopts ':atfp:' OPTION; do
    case $OPTION in
    a) # Apache support
        MAIN_CONF="--with-apxs2=$(which apxs2)"
	;;
    f) # Fast CGI support
        MAIN_CONF="$MAIN_CONF --enable-fpm --with-fpm-user=$WEB_USR --with-fpm-group=$WEB_GROUP"
       ;;
    t) # Enable thread safe
        MAIN_CONF="$MAIN_CONF --with-tsrm-pthreads --enable-maintainer-zts" 
        ;;
    p) # Install prefix
        PREFIX=$OPTARG
        ;;
    ?) # Help
        echo -e "Usage: build \033[0m \033[32m[-a|-f] [-d] [-p]\033[0m  \033[33msource_dir"
        echo -e "  Arguments:"
        echo -e "    \033[33msource_dir\033[0m     php source directory, example: '~/php/php-5.4'"
        echo -e "  Options:"
        echo -e "    \033[32m-a\033[0m        build with apache support"
        echo -e "    \033[32m-t\033[0m        enable thread safe"
        echo -e "    \033[32m-f\033[0m        build with fpm support"
        echo -e "    \033[32m-p\033[0m        Install DIR prefix"
        echo -e "\n  When finished, run make install afterwards, or make test first"
        exit
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

EXTENSION_DIR=$PREFIX/lib/php/modules
export EXTENSION_DIR
PEAR_INSTALLDIR=$PREFIX/share/pear
export PEAR_INSTALLDIR

[[ ! -d "$SYSCONFDIR" ]] && { 
    echo -e "You must create config dirs: $SYSCONFDIR, $SYSCONFDIR/conf.d, $EXTENSION_DIR, $PEAR_INSTALLDIR"
        echo -e Bye!!!
        exit 3; 
} 

[[ ! -d "$EXTENSION_DIR" ]] && { echo -e "You must create extension dir: $EXTENSION_DIR"; echo -e Bye!!!; exit 4; }

[[ ! -d "$PEAR_INSTALLDIR" ]] && { echo -e "You must create PEAR dir: $PEAR_INSTALLDIR"; echo -e Bye!!!; exit 5; }

# new icu libs for intl does not include this stdc++ lib ld flag
EXTRA_LIBS=-lstdc++
export EXTRA_LIBS

MAIN_CONF="--config-cache \
--prefix=$PREFIX \
--sbindir=$PREFIX/bin \
--sysconfdir=$SYSCONFDIR \
--localstatedir=/var \
--with-layout=GNU \
--with-config-file-path=$SYSCONFDIR \
--with-config-file-scan-dir=$SYSCONFDIR/conf.d \
--disable-rpath \
--mandir=$PREFIX/share/man \
--with-pear \
--with-readline \
--enable-cgi \
--enable-pcntl \
$MAIN_CONF"

ESSENTIAL_EXT="--enable-posix \
--enable-zip \
--enable-intl \
--enable-soap \
--enable-sockets \
--enable-mbstring \
--enable-mbregex \
--enable-inline-optimization \
--with-bz2 \
--with-gd \
--with-xpm-dir=/usr \
--with-jpeg-dir=/usr \
--with-png-dir=shared,/usr \
--with-freetype-dir=/usr \
--with-curl=/usr/bin \
--with-regex=php \
--with-pcre-regex=/usr \
--with-zlib-dir=/usr \
--with-mysqli=mysqlnd \
--with-mysql-sock=/var/run/mysqld/mysqld.sock \
--with-pdo-mysql=mysqlnd \
--with-openssl \
--with-openssl-dir=/usr/bin \
--with-mcrypt=/usr \
--with-icu-dir=/usr \
--with-gettext \
--with-iconv-dir=/usr \
--with-sqlite3=/usr \
--with-pdo-sqlite \
--enable-phar \
--enable-ftp \
" 

# System V semaphore support
SYSV_SUPPORT="--enable-sysvmsg \
--enable-sysvsem \
--enable-sysvshm \
"

# Postgre support
PG_SUPPORT="
--with-pgsql=/usr \
--with-pdo-pgsql=/usr"

EXTRA_OPTS="--enable-exif \
--enable-calendar \
--with-snmp=/usr \ 
--with-pspell \
--with-tidy=/usr \
--with-xmlrpc \
--with-xsl=/usr"
 

if [[ "$1" =~ [[:digit:]]+(\.[[:digit:]]+)? ]]; then
    [[ ${BASH_REMATCH} > 5 ]] && MAIN_CONF="$MAIN_CONF --enable-opcache"
fi

cd "$1"

if [ ! -f "$DIR/configure" ]; then
    ./buildconf --force # build configure, not included in git versions
fi


./configure ${MAIN_CONF} ${ESSENTIAL_EXT} ${SYSV_SUPPORT} 

make
