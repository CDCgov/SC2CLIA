#!/bin/bash


# run_NCBI_UPLOAD.sh script under each run folder
ID=samples.txt
TEMPLATE=template.csv
BIN=../../../Pipeline/SC2CLIA/Cecret/bin
FSA_FILE=submission.fsa
SRC_FILE=submission.src
SBT_TABLE=submission.sbt
SUB_DIR=submission_dir


if [ ! -s "${ID}" ]; then
    echo "Error!  Can't find $ID";
    exit 1;
fi

# 1. Fasta File
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


# 2. Source Modifier File
# Takes in a `samples.txt` file with list of sequence_ids. Uses CSID to extract metadata
# Prints a source modifier file that is redirected into $SRC_FILE
python3 $BIN/make_src.py > $SRC_FILE 2> make_src.err

# 3. Submission Template File
# Takes in two CSV file for user input: author_template.csv and submission_template.csv 
# Prints a submission template file that is redirected into $SBT_FILE
python3 $BIN/make_sbt.py > $SBT_TABLE 2> make_sbt.err

# 4. Submission.zip
# Zips the .fsa, .sbt., and .src file into `submission.zip`
# Deletes the original files
if [ -d $SUB_DIR ]; then
	rm -rf $SUB_DIR
	echo "Deleting previous $SUB_DIR"
fi
mkdir $SUB_DIR
zip -rm $SUB_DIR/submission.zip $FSA_FILE $SRC_FILE $SBT_TABLE

# 5. Submission XML file
python3 $BIN/csv_to_submissionXML.py
mv submission.xml $SUB_DIR

# 6. submit.ready
touch $SUB_DIR/submit.ready && chmod 664 $SUB_DIR/submit.ready

# 7. Submit_to_genbank scripts copied into submission folder
cp $BIN/submit_to_genbank.sh $SUB_DIR
cp $BIN/submit_to_genbank.py $SUB_DIR

### TO DO  check sequence_id
# a)	sequence IDs must be unique for each sequence
# b)	cannot contain spaces 
# c)	may contain only the following characters - letters, digits, hyphens (-), underscores (_), periods (.), colons (:), asterisks (*), and number signs(#).
# d)	Under 25 characters
