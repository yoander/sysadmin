#!/usr/bin/env bash

USR_ALIAS=

if [[ 'root' != $(whoami) ]]; then
    USER_ALIAS=$(which sudo)
    [[ '' == $USER_ALIAS ]] && { echo You need sudo tool for installing php development dependencies!!!; exit 1; }
fi

# Posible value: apache-prefork|apache-worker|nginx or empty value for no web server
WEB_SRV=

[[ $1 != '' ]] && WEB_SRV=$1

# Debian/Ubuntu distro
if egrep -i 'debian|ubuntu' /etc/issue > /dev/null; then
    case $WEB_SRV in
        'apache-prefork') WEB_SRV_PKG='apache2 apache2-mpm-prefork apache2-prefork-dev';;
        'apache-worker') WEB_SRV_PKG='apache2 apache2-mpm-worker apache2-threaded-dev';;
        'nginx') WEB_SRV_PKG='nginx';;
        # No install any web server and its dependencies
        '') WEB_SRV_PKG=;; 
        *) echo Unknown web server: adjust the script by yourself, bye!; exit 2;;
    esac
   $USER_ALIAS  apt-get install -y make autoconf gcc libxml2-dev libssl-dev openssl \
       libpcre3-dev libsqlite3-dev libbz2-dev libcurl4-openssl-dev libgd2-xpm-dev \
       libicu-dev libmcrypt-dev libpq-dev libreadline-dev $WEB_SRV_PKG bison flex re2c libtool \
       $(apt-cache search -n '^libstdc\+\+\-(\.?[[:digit:]])+\1*\-dev$'|sort -r|head -n 1|awk '{print $1}') \
       $(apt-cache search -n '^g\+\+\-(\.?[[:digit:]])+\1*$'|sort -r|head -n 1|awk '{print $1}')

    $USER_ALIAS ln -fs /lib/$(arch)-linux-gnu/libpcre.so.3 /usr/lib/libpcre.so && \
    $USER_ALIAS ln -fs $(find /usr/bin/ -name 'g++-*') /usr/bin/g++

    if [[ 'apache-prefork' == $WEB_SRV || 'apache-worker' == $WEB_SRV ]]; then
        $USER_ALIAS cp -p /var/www/index.html /var/www/info.php && \
        $USER_ALIAS bash -c "echo '<?php phpinfo();' > /var/www/info.php" && \
        $USER_ALIAS wget https://raw.githubusercontent.com/yoander/sysadmin/master/conf/php5.conf -O /etc/apache2/mods-available/php5.conf && \
        $USER_ALIAS ln -s /etc/apache2/mods-available/php5.conf /etc/apache2/mods-enabled/php5.conf
    elif [[ 'nginx' == $WEB_SRV ]]; then
        $USER_ALIAS cp -p /usr/share/nginx/www/index.html /usr/share/nginx/www/info.php && \
        $USER_ALIAS bash -c "echo '<?php phpinfo();' > /usr/share/nginx/www/info.php"
    fi
# Centos/RHEL distro
elif grep -i 'centos' /etc/redhat-release > /dev/null; then
    # Put here yum -y install packages
    $USER_ALIAS yum -y install gcc gcc-c++ make autoconf flex bison libtool libstdc++-devel \
        epel-release libxml2-devel openssl openssl-devel pcre-devel sqlite-devel bzip2-devel \
        libcurl-devel libicu-devel gd-devel readline-devel libmcrypt-devel
else
    echo This is script is intended for Debian GNU/Linux base family distro.\
        If you are using another GNU/Linux distribution then you need to adjust the script\
        by yourself. Thanks!
    exit 2;
fi

exit 0;
