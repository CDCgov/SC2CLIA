### Cecret R Singularity README Stub

***

#### Purpose
Currently all R-based scripts and versions.sh execute within a custom Singularity container built for this pipeline from the outside. In future versions the scripts will be included in the container.

#### Requires
* All  
  * Singularity v.3.7.3+  
* Build  
  * Cecret/configs/singularity-r.def: the Singularity definition file for the container  
  * Sudo permissions on the host machine where the build is occurring (note AJW has been building on her Linux   subsystem for Windows)  
* Test  
  * Singularity container (*.sif) built from Cecret/configs/singularity-r.def  
  * Cecret/bin/report/testrcontainer.Rscript  

#### Use
* To build container
  * `sudo singularity build singularity-YourContainerName.sif singularity-r.def`  
* To test container manually (does not require sudo)
  * `singularity exec --bind /mnt,/path/to/host/directory/containing/all/files/required/for/analysis singularity_container_name.sif Rscript test_r_container.Rscript`  
  * Note that as of v1.1 this script is automatically run as a part of the build process (see %test section in def file).  
* To run container (does not require sudo)
  * `singularity exec --bind /mnt,/path/to/host/directory/containing/all/files/required/for/analysis singularity_container_name.sif Rscript script_name.R <args>`  
  * Note the mount point in the host directory tree must include both the required scripts and the required input files.
* To see container help file (does not require sudo)
  * `singularity run-help singularity-container-name.sif`

#### Outputs
* From build
  * singularity-YourContainerName.sif  
* From testing
  * Print out to screen of R environment with all packages successfully loaded  
* From running
  * Script dependent
