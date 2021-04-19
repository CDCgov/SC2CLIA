while getopts ":f:x:z:o" opt; do
    case ${opt} in
        d)
            fasta_directory="$OPTARG";;
        x)
            xml_template="$OPTARG";;
        z)
            zip_filename="$OPTARG";;
        r)
            cuids="$OPTARG";;
        o)
            output_directory="$OPTARG";;
    esac
done

SC2CLIA_base=" ***replace with your own path here***
Run_id="Run_2021.04.01-22.11.42_runs"

# fasta_directory=" ***replace with your own path here***
fasta_directory="${SC2CLIA_base}/${Run_id}/consensus"
xml_template="${SC2CLIA_base}/Cecret/configs/submission.xml"
zip_filename="sarscov2.zip"
cuids="6786378,4737284"
output_directory="${SC2CLIA_base}/${Run_id}/test_submission_20210416"

# Create the output directory
echo "made ${output_directory}"
mkdir -p ${output_directory}

# Merge the fasta files into one .fsa file
echo "merged fastas"
cat ${fasta_directory}/*.fa > ${output_directory}/submission.fsa

# Create the submission template (.sbt) file
echo "Made .sbt"
python3 make_sbt.py authors_file submitter_file > ${output_directory}/submission.sbt

sample_file="samples.txt"

# Create the source modifer (.src) file
echo "Made .src"
python3 make_src.py sample_file > ${output_directory}/submission.src2

# Copy the xml into the output directory
# Here is where to run Rong's script to update any xml fields
echo "Made .xml"
cp ${xml_template} ${output_directory}

# Create submit to ready to indicate submission folder is complete
echo "Made submit.ready"
touch ${output_directory}/submit.ready && chmod 664 ${output_directory}/submit.ready

# Zip file
# Not currently zipping files

echo "DONE!"
