#!/bin/bash


# run_NCBI_UPLOAD.sh script  under each run folder
ID=samples.txt
TEMPLATE=template.csv
BIN=../../Cecret/bin
FSA_FILE=submission.fsa
SRC_FILE=submission.src
SBT_TABLE=submission.sbt


if [ ! -s "${ID}" ]; then
    echo "Error!  Can't find $ID";
    exit 1;
fi

# 1. fsa
# erase previous $FSA_FILE
rm -f $FSA_FILE
# assume sequence_id is the ARTIFACT_ID (CSID-CUID-ARTIFACT_ID)
cat $ID | while read LINE; do 
	# sequence_id=$(echo $LINE | cut -d '-' -f 3);
	# use CUID as sequence_id for now !!
	sequence_id=$(echo $LINE | cut -d '-' -f 2);
	echo '>'$sequence_id >> $FSA_FILE
	awk 'FNR == 2 {print}' ../consensus/*$LINE*.fa >> $FSA_FILE
done


# 2. src
# python script ?  takes in a txt file with list of sequence_id (and get the csid from sequence_id ?)
#python3 $BIN/src.py sample.txt > $SRC_FILE
touch $SRC_FILE

# 3. sbt
# pythong script ?  takes in CSV file for user input 
#python3 $BIN/sbt.py template1.csv template2.csv > $SBT_TABLE
touch $SBT_TABLE

# 4. generate: submission.zip, 
rm -rf submission_file
mkdir submission_file
zip submission_file/submission.zip $FSA_FILE $SRC_FILE $SBT_TABLE
rm -f $FSA_FILE $SRC_FILE $SBT_TABLE

# 5. submission.xml
python3 $BIN/csv_to_submissionXML.py
mv submission.xml submission_file/

# 6. submit.ready
touch submission_file/submit.ready && chmod 664 submission_file/submit.ready



### TO DO  check sequence_id
# a)	sequence IDs must be unique for each sequence
# b)	cannot contain spaces 
# c)	may contain only the following characters - letters, digits, hyphens (-), underscores (_), periods (.), colons (:), asterisks (*), and number signs(#).
# d)	Under 25 characters
