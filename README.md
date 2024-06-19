# SIEM_Snort
Workspace for configurating a Snort Docker container 
Contributor: Anh Nhat NGUYEN
 How to run
  The content of Dockerfile should be copied into the same build directory of the official container, running on eth0
  snort.lua and local.rules should also be in the same directory
  docker compose <job>
  If Snort cannot run you need to execute the container using root
         -docker exec --user root -it <container-id> /bin/bash
  Done and done
