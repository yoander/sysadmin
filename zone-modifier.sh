#!/usr/bin/env bash
LOG_FILE="$(pwd)/zone-modifier.log"
echo -e "Starting zone modifer at: $(date)\n" > $LOG_FILE
CHECK_ZONE=$(which named-checkzone)
RNDC=$(which rndc)
SUFFIX='.hosts'
HTTP_CONF="$1"
ZONES_DIR="$2"
DATE=$(date +%Y%m%d)
ZONES=$(grep -Eoi '(servername|serveralias)\s*www.\w*[-_]?\w*\.[a-z]{2,3}' $HTTP_CONF | sed -e 's/\./ /' | awk 'BEGIN {FS=" "} {print $3;}' | sort | uniq)
#ZONES=$(grep -oi 'servername.*' $HTTP_CONF | awk 'BEGIN {FS= " "} {print $2}' | sort)
for zone in $ZONES;do
	FILE="$ZONES_DIR/$zone$SUFFIX"
	echo -e "Proccessing $zone ($FILE)" >> $LOG_FILE
	
	# Modify serial number
	SERIAL=$(egrep -o '[0-9]{1,10}\s*;\s*serial' $FILE | egrep -o '[0-9]{1,10}')
	
	[[ "$SERIAL" =~ '([[:digit:]]{8})([[:digit:]]{1,2})' ]] || { echo "Invalid serial format: $SERIAL" >> $LOG_FILE; exit; }
	[[ "$DATE" == ${BASH_REMATCH[1]} ]] && INC=$((10#${BASH_REMATCH[2]}+1)) || INC=${BASH_REMATCH[2]}
	 
	[[ 1 == ${#INC} ]] && INC="0$INC"	

	NEWSERIAL="$DATE$INC"
	echo "New serial: $NEWSERIAL" >> $LOG_FILE
	
	sed -r -i  '/serial/s/[0-9]{1,10}/'$NEWSERIAL'/' $FILE && echo -e "--- Serial has been changed\n" >> $LOG_FILE
	
	# modify hosting
	sed -r -i 's/IP1/IP2/' $FILE && echo -e "--- Hosting has been changed\n" >> $LOG_FILE
 
	#Reload zone
	$CHECK_ZONE $zone $FILE && (echo "$zone OK" >> $LOG_FILE) || (echo "Error checking $zone" >> $LOG_FILE)
	#($CHECK_ZONE $zone $FILE && $RNDC reload $zone IN internacional) 2>&1 >> $LOG_FILE ||  echo "error: Reloading $zone" >> $LOG_FILE  
done
