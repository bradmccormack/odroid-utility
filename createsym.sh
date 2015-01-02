#!/bin/bash
PWD=($PWD)
FILES=`ls *.sh`
for FILE in $FILES; do
	rm -f /usr/local/bin/$FILE
	ln -s $PWD/$FILE /usr/local/bin/$FILE	
done
echo "/usr/local/bin shell scripts related to odroid utility have been removed and replaced with sym links at $PWD"


