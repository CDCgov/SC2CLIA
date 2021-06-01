### Cecret R Singularity README Stub

***

#### Purpose
Container for executing all R-based scripts and versions.sh for the CDC CLIA version of Cecret.  
Prior to version 2.0, all R-based scripts and versions.sh execute within this custom Singularity container from the outside. As of version 2.0, the scripts are included in the container.

#### Requires
* All  
  * Singularity v.3.7.3+  
* Build  
  * Cecret/configs/singularity-r.def: the Singularity definition file for the container  
  * Sudo permissions on the host machine where the build is occurring (note AJW has been building on her Linux   subsystem for Windows)  
* Test  
  * Singularity container (*.sif) built from Cecret/configs/singularity-r.def  
  * From repo: Cecret/bin/report/test_r_container.R or from container: /opt/test_r_container.R  
* Execute as a part of the Cecret pipeline  
  * Singularity container (*.sif) built from Cecret/configs/singularity-r.def  
  * Sequencing run ID  
  * Cecret analysis directory __full path on host system__  
  * Sequencing run directory __full path on host system__  

#### Use
* To build container
  * You __must__ build from Cecret/configs in the cloned repo in order for the paths referenced in the def file to be valid.  
  * `sudo singularity build singularity-YourContainerName.sif singularity-r.def`  
* To test container manually (does not require sudo)  
  * `singularity exec --bind /mnt,</path/to/host/directory/containing/all/files/required/for/analysis> <singularity_container_name.sif> Rscript test_r_container.R`  
  * Note that as of v1.1 this script is automatically run as a part of the build process (see %test section in def file).  
* To run container (does not require sudo)
  * Note  
    * As of v2.0 each script is installed in the container as a separate app and must be called individually as a part of the pipeline.  
    * The mount point in the host directory tree must be high enough to include all required input files and output locations below it.  
  * `singularity --bind /mnt,<hostMntPt> exec --app orf_table <singularity_container_name.sif> <runID> <analysisDirFP>`  
  * `singularity --bind /mnt,<hostMntPt> exec --app append_tables <singularity_container_name.sif> <analysisDirFP> <file1FP> <file2FP>`  
  * `singularity --bind /mnt,<hostMntPt> exec --app report <singularity_container_name.sif> <runID> <analysisDirFP> <seqDirFP>`  
  * Definitions  
    * <runID> = Sequencing run ID (string)  
    * <analysisDirFP> = Cecret output directory __full path__ (string)  
    * <seqDirFP> = Full path to sequencing run __full path__ (string)  
    * <file1FP> = Table file 1 with path for append_tables.R (string)  
    * <file2FP> = Table file 2 with path for append_tables.R (string)  
* To access help files
  * Container: `singularity run-help <singularity-container-name.sif>`  
  * Individual scripts: `singularity run-help --app <appName> <singularity-container-name.sif>`  

#### Outputs
* From build  
  * singularity-container-name.sif  
* From testing  
  * Print out to screen of R environment with all packages successfully loaded  
* From running  
  * [orf_table](orf_table_README_stub.md)  
  * append_tables: see script help  
  * [report](report_README_stub.md)  

