#!/usr/bin/env bash

# Author: Rong Jin ***REMOVED***, Jo Williams ***REMOVED***
# Support: SC2CLIA-Cecret@cdc.gov
# Date: 2021-04-15
# Use: ./versions.sh <cecretOutputDirFullPath> 
# Function: Run from the Cecret bin directory to collect component software versions. Currently launched by config.R in bin/report.
# Output: versions.txt in Cecret output directory root.
# Future dev: Replace with proper Cecret configs and harvest from there.

# First loop for the components that create log files
for dir in "${1}"/logs/*; do
  if [[ -d "$dir" ]]; then
    BD=$(basename "$dir")
    if [[ "${BD}" != "summary" ]]; then
      files="${dir}"/*.log
      first_file=${files[0]}
      VERSION=$(sed -n '2{p;q}' $first_file)
      echo "$(basename ${dir}): ${VERSION}" >> "${1}"/versions.txt
    fi
  fi
done

# For components that don't produce log files
# Commenting out because they couldn't be called when executing this script from within the R container.
# multiqc
# D=$(dirname "${1}")
# MQC=$(singularity exec $D/SINGULARITY_CACHE/ewels-multiqc-latest.img multiqc --version)
# echo "multiqc: $MQC" >> "${1}"/versions.txt
# # pacbam
# PB=$(singularity exec $D/SINGULARITY_CACHE/cibiobcg-pacbam-latest.img pacbam 2>&1)
# PBO=$(echo $PB | sed 's/\sUsage.*//')
# echo "pacbam: $PBO" >> "${1}"/versions.txt
# # vadr
# V=$(ls $D/SINGULARITY_CACHE | grep -o 'vadr.*[^.img]')
# echo "vadr: $V" >> "${1}"/versions.txt

