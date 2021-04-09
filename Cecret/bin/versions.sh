#!/bin/bash

# Author: Rong Jin ***REMOVED***, Jo Williams ***REMOVED***
# Date: 2021-04-09
# Use: ./versions.sh <cecretOutputDir> 
# Function: Run from the Cecret bin directory to collect component software versions. Currently launched by config.R in bin/report.
# Output: versions.txt in Cecret output directory root.
# Future dev: Replace with proper Cecret configs and harvest from there.

# First loop for the components that create log files
for dir in logs/*; do
  if [[ -d "$dir" ]]; then
    if [[ "$dir" != "logs/summary" ]]; then
      files=($dir/*.log)    
      first_file=${files[0]}
      VERSION=$(sed -n '2{p;q}' $first_file)
      echo "$(basename ${dir}): ${VERSION}" >> versions.txt
    fi
  fi
done

# For components that don't produce log files
# multiqc
../SINGULARITY_CACHE/ewels-multiqc-latest.img --version >> versions.txt
# pacbam
PB=$(../SINGULARITY_CACHE/cibiobcg-pacbam-latest.img 2>&1)
echo $PB | sed 's/\sUsage.*//' >>versions.txt
# vadr
ls ../SINGULARITY_CACHE | grep -o 'vadr.*[^.img]' >> versions.txt
