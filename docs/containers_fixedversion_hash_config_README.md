## container_fixedversion_hash.config README

***

### Purpose
A central place to hold the container version information for all the processes in the SC2CLIA pipeline.   

For each process, it defines only the current version of container, and the version information has 2 lines, the first line is the standard text version for the container version(and it's commented out), the second line is the hashed container version. For example:

    //container = 'staphb/fastqc:0.11.9'
    container = 'staphb/fastqc@sha256:38bf27acfc4a32d4ec5ad1f1fe3b4d08850754f75bbf7f1e8121ca9a888e0968'

That first line of text version of container version is there to be extracted by a script to generate a containers_version.txt file