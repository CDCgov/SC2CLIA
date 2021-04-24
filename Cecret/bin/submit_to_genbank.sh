#!/bin/sh

# Must include the password as argument
# if [[ $# -eq 0 ]] ; then
#     echo 'Must provide FTP password!'
#     echo 'usage: ./submit_to_genbank.sh PSSWRD'
#     exit 0
# fi

echo "Enter the 8-digit FTP password"
read -s PASSWD
 

HOST='ftp-private.ncbi.nlm.nih.gov'
USER='CDC-SC2CLIA'
SUBTYPE="Test" # Production
FTPDIR="${USER}_$(date "+%Y.%m.%d-%H.%M.%S")"

LOG='submit.log'

echo "Logging into ${HOST}"

# Log in to check valid credentials
ftp -n $HOST <<END_SCRIPT > ${LOG}
quote USER $USER
quote PASS $PASSWD
quit
END_SCRIPT

# Check if the error file has a incorrect login message.
grep 'Login incorrect.' ${LOG} > /dev/null 2>&1

# Inform user if they entered an invalid password
if [ $? -eq 0 ]
then
    echo "There was a problem with your password, try it again."
    exit 1
fi

# Submission starts here
echo "Adding submission file to Genbank folder..."

ftp -n $HOST <<END_SCRIPT > ${LOG}
quote USER $USER
quote PASS $PASSWD
cd Test
mkdir $FTPDIR
cd $FTPDIR
put submission.xml
put submission.zip
put submit.ready
quit
END_SCRIPT

# Tell user what happened
echo -e "...Done! Files uploaded from \n${PWD}."
echo -e "Submission is in \nTest/${FTPDIR}"

exit 0
