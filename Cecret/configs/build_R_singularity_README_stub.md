### Cecret R Singularity README Stub

***

#### Purpose
Currently all R-based scripts and versions.sh execute within a custom Singularity container built for this pipeline from the outside. In future versions the scripts will be included in the container.

#### Requires
_All_  
* Singularity v.3.7.3+  
_Build_  
* Cecret/configs/singularity-r.def: the Singularity definition file for the container  
* Sudo permissions on the host machine where the build is occurring (note AJW has been building on her Linux   subsystem for Windows)  
_Test_  
* Singularity container (*.sif) built from Cecret/configs/singularity-r.def  
* Cecret/bin/report/test_r_container.Rscript  

#### Use
_To build container_  
`sudo singularity build singularity-YourContainerName.sif singularity-r.def`  
_To test container (does not require sudo)_  
`singularity exec --bind /mnt,/path/to/host/directory/containing/all/files/required/for/analysis singularity_container_name.sif Rscript test_r_container.Rscript`  
_To run container (does not require sudo)_  
`singularity exec --bind /mnt,/path/to/host/directory/containing/all/files/required/for/analysis singularity_container_name.sif Rscript script_name.R <args>`  
Note the mount point in the host directory tree must include both the required scripts and the required input files.

#### Outputs
_From build_  
singularity-YourContainerName.sif  
_From testing_  
Print out to screen of R environment with all packages successfully loaded  
_From running_  
Script dependent  