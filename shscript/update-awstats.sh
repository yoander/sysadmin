#!/usr/bin/env bash
CURRENT_DATE=$(date +%Y%m%d)
SRC_SRV=
SRC_PATH=/var/log/httpd/
FILE_NAME=access_log.1.gz
DEST_PATH=/mnt/logs/www/
NEW_FILE_NAME=access-log.$CURRENT_DATE.gz
AWSTATS_SRV=
AWSTATS_WWW_LOGS_DIR=/mnt/logs/www/
AWSTATS_PL='/usr/share/awstats/wwwroot/cgi-bin/awstats.pl'
LOG=/var/log/update.awstats.log
DOMAIN=
EMAIL= 

echo "Starting AWSTATS update proccess for $DOMAIN, DATE: $(date)" > $LOG

# Write a blank line
echo -e "\n"

while ! rsync -e ssh -avz root@$SRC_SRV:$SRC_PATH$FILE_NAME $DEST_PATH 2>> $LOG; do
 	sleep 2h
done

# Replace log file name with current one
sed -i -r  's/(^LogFile=.*\/)access-log.*(\s+\|?)"/\1'$NEW_FILE_NAME'\2"/' /etc/awstats/awstats.www.solmeliacuba.com.conf

(cp -vpf $DEST_PATH$FILE_NAME $DEST_PATH$NEW_FILE_NAME && rm -fv $DEST_PATH$FILE_NAME && $AWSTATS_PL -config=$DOMAIN -update) >> $LOG

mail -s "AWSTATS $DOMAIN"$EMAIL < $LOG  
