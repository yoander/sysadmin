#/usr/bin/env bash

USR_ALIAS=

if [[ 'root' != $(whoami) ]]; then
    USER_ALIAS=$(which sudo)
    [[ '' == $USER_ALIAS ]] && { echo You need sudo tool for installing php development dependencies!!!; exit 1; }
fi

APACHE_PREFORK='apache2 apache-mpm-prefork apache2-prefork-dev'
APACHE_WORKER='apache2 apache-mpm-prefork apache2-prefork-dev'
NGINX='nginx'

# Debian/Ubuntu distro
if egrep -i 'debian|ubuntu' /etc/issue > /dev/null; then
    $USER_ALIAS apt-get -y install make autoconf gcc libxml2-dev libssl-dev openssl \
         libpcre3-dev libsqlite3-dev libbz2-dev libcurl4-openssl-dev libgd2-xpm-dev \
         libicu-dev libmcrypt-dev libpq-dev libreadline-dev $APACHE_PREFORK bison \
         flex re2c libtool g++ libstdc++6-4.7-dev

    
    $USER_ALIAS ln -s /lib/$(arch)-linux-gnu/libpcre.so.3 /usr/lib/libpcre.so
    $USER_ALIAS ln -s /usr/lib/gcc/$(arch)-linux-gnu/4.7/cc1 /usr/lib/gcc/$(arch)-linux-gnu/4.7/cc1plus
    $USER_ALIAS cp -p /var/www/index.html /var/www/info.php
    $USER_ALIAS bash -c "echo '<?php phpinfo();' > /var/www/info.php"

    $USER_ALIAS wget https://raw.githubusercontent.com/yoander/sysadmin/master/php5.conf -O /etc/apache2/mods-available/php5.conf
    $USER_ALIAS ln -s /etc/apache2/mods-available/php5.conf /etc/apache2/mods-enabled/php5.conf

# Centos/RHEL/Fedora distro
#elif grep -i 'centos|fedora' /etc/issue > /dev/null; then
#    # Put here yum -y install packages
#    echo Put your package manager
else
    echo This is script is intended for Debian GNU/Linux base family distro.\
        If you are using another GNU/Linux distribution then you need to adjust the script\
        by yourself. Thanks!
    exit 2;
fi

exit 0;
