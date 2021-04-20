#!/bin/sh

# Must include the password as argument
if [[ $# -eq 0 ]] ; then
    echo 'Must provide FTP password!'
    echo 'usage: ./submit_to_genbank.sh PSSWRD'
    exit 0
fi

HOST='ftp-private.ncbi.nlm.nih.gov'
USER='CDC-SC2CLIA'
PASSWD=$1
FTPDIR="${USER}_$(date "+%Y.%m.%d-%H.%M.%S")"

echo $FTPDIR
echo $PASSWD

ftp -n $HOST <<END_SCRIPT
quote USER $USER
quote PASS $PASSWD
cd Test
mkdir $FTPDIR
cd $FTPDIR
lcd
put submission.xml
put submission.zip
put submit.ready
ls
quit
END_SCRIPT
exit 0
