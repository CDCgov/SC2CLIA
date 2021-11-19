## Singularity Config README

***

### Purpose
Custom configuration file for the CDC CLIA version of Cecret.  


##### -- singularity
The singularity configuration scope controls how Singularity containers are executed by Nextflow.  
(Ex: cacheDir = "SINGULARITY_CACHE". This will save all remote singularity images to this folder in current working directory)

##### -- process
The process configuration scope allows you to provide the default configuration for the processes in your pipeline.  
(note you can overwrite this in the actual workflow script)

##### -- profiles
A profile is a set of configuration attributes grouped together using a common prefix.   
We have 2 different profiles v3 and v4 (different by the artic primers they use, either v3 or v4; v3 is set as the default profile in `run_cecret.sh`)


### Resource

[nextflow_config](https://www.nextflow.io/docs/latest/config.html) - official nextflow configuration docs