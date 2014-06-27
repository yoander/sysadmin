#!/usr/bin/env bash
# Shell script utility to read a file line line.
# Once line is read it can be process in fixperm() function
# You can call script as follows, to read myfile.txt:
# ./readline myfile.txt
# Following example will read line from standard input device aka keyboard:
# ./readline
# -----------------------------------------------
# Copyright (c) 2005 nixCraft <http://cyberciti.biz/fb/>
# This script is licensed under GNU GPL version 2.0 or above
# -------------------------------------------------------------------------
# This script is part of nixCraft shell script collection (NSSC)
# Visit http://bash.cyberciti.biz/ for more information.
# -------------------------------------------------------------------------
# Moified by yoander.valdes at gmail.com
 
# User define Function (UDF)
fixperm() {
  line="$@" # get all args
  #  just echo them, but you may need to customize it according to your need
  # for example, F1 will store first field of $line, see readline2 script
  # for more examples
  # F1=$(echo $line | awk '{ print $1 }')
  echo $line
}
 
### Main script stars here ###
# Store file name
FILE=""
 
# Make sure we get file name as command line argument
# Else read it from standard input device
if [ "$1" == "" ]; then
   FILE="/dev/stdin"
else
   FILE="$1"
   # make sure file exist and readable
   if [ ! -f $FILE ]; then
  	echo "$FILE : does not exists"
  	exit 1
   elif [ ! -r $FILE ]; then
  	echo "$FILE: can not read"
  	exit 2
   fi
fi
# read $FILE using the file descriptors
 
# Set loop separator to end of line
BAKIFS=$IFS
IFS=$(echo -en "\n\b")
exec 3<&0
exec 0<$FILE
while read line
do
	# use $line variable to process line in fixperm() function
	fixperm $line
done
exec 0<&3
 
# restore $IFS which was used to determine what the field separators are
BAKIFS=$ORIGIFS
exit 0
