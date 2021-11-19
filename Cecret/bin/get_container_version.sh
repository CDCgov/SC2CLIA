#!/bin/bash

# this script will parse the container config file to retrieve the version info
# this script can be called upon as: ./get_container_version.sh -i path-to-config-file -o path-to-saved-version.txt 
usage() { echo "Usage: $0 <-i  specify config file> <-o specify path-to-saved-file>" 1>&2; exit 1; }

while getopts "i:o:" o; do
	case $o in
		i) CONFIG=${OPTARG} ;;
		o) OUTPUT=${OPTARG} ;;
		*) usage ;;
	esac
done

if [ ! -f "${CONFIG}" ]; then
	echo "Missing ${CONFIG} !";
	exit 1;
fi



# grep: print out all lines that contain either 'withName' or 'container'
# sed: remove 'withName:', 'container =', all single quotes, all leading spaces and tabs, all lines that have '\\'
# sed: replace '{' with ':'
# sed: delete all empty lines
# awk: if a line ends with ':', replace '\n' with '\t'
grep -E 'withName|container' $CONFIG | \
	sed -e "s/withName://;s/container =//;s/{/:/;s/'//g;s/^[ \t]*//;s/\/\/.*//g" | \
	sed '/^$/d' | awk '{ if ($0 ~ /.*:$/) {ORS="\t";print $0} else{ORS="\n";print $0} }' | sort \
	> $OUTPUT