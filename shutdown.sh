#!/bin/bash

CONTAINERS=`docker ps | grep "NAMES\|zookeeper" | awk 'NR==1{ NAMESPOS=index($0,"NAMES"); } NR>1{  NAMES=substr($0, NAMESPOS); print NAMES }'`

#for i in {1..4} ; do
#  docker rm -f kafka${i}
#done

for i in ${CONTAINERS} ; do
  docker stop ${i}
  docker rm -f ${i}
done

#for i in {1..5} ; do
#  docker rm -f api${i}
#done
