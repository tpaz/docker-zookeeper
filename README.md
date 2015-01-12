docker-zookeeper
================

A configurable # of nodes zookeeper ensemble that runs in Docker

Note: the wouterd/zookeeper image is in the docker index as an "automated build", so you don't have to build the 
Dockerfile in the zookeeper folder.

Start ensemble by running:

    ./startup.sh <# of nodes>
    
From the root of the project.

This will:

- Create a config container
- Create n-1 zookeeper containers that wait for a config file to appear on the config container
- Generate the configuration
- Push the configuration into the config container
- Start the ensemble
