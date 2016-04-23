#!/usr/bin/python
import os
import re
import HTMLParser as parser
import xml.dom.minidom as minidom
import sys

# Read an enviroment variable 
# env = os.getenv('GEDIT_CURRENT_DOCUMENT_PATH')

try:
    # Read de file name from standard input
    filename = sys.argv[1]
    if os.path.isfile(filename) and os.access(filename, os.R_OK):
        # Open the file in read only mode
        file = open(filename, 'r')
        
        # Read the file and decode html entities
        xml = parser.HTMLParser().unescape(file.read())

        # Remove anonying piece of words at begining and at the end
        xml = re.sub('^s:[0-9]+:"', '', xml)
        xml = re.sub('";.*$', '', xml)

        # Pretify the xml
        xml = minidom.parseString(xml).toprettyxml()

        # Handle issue with CDATA section due minidom add extraspace
        # before/after CDATA
        xml = re.sub('>\s+<!', '><!', xml)
        xml = re.sub(']>\s+<', ']><', xml)

        # Remove empty lines
        # Thanks to http://stackoverflow.com/questions/1140958/whats-a-quick-one-liner-to-remove-empty-lines-from-a-python-string
        print "".join([s for s in xml.strip().splitlines(True) if s.strip()])
    else:
        print "File is missing or is not readable!"
except IndexError:
    print "You must specify a file name!"
