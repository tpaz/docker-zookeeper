#!/bin/bash

set -e

ZOOKEEPER_NODES=5

if [ $# -lt 1 ] ; then
  echo "Usage: $0 <# of zookeeper nodes>. Minimum 2"
  echo "Using default: 5" 
else
  if [ $1 -lt 2 ] ; then
    echo "not enough nodes. minimum set to 2"
    exit 1
  fi
  ZOOKEEPER_NODES=$1
fi

if [ ! ${nopull} ] ; then
  echo 'Pulling all images needed, just to be sure'
  docker pull busybox
  docker pull wouterd/zookeeper
#  docker pull wouterd/kafka
fi

# Need a volume to read the config from
conf_container=zoo1

# Start the zookeeper containers
for i in $(seq 1 $ZOOKEEPER_NODES) ; do
  if [ ${i} -eq 1 ] ; then
    docker run -d -v /zoo/conf --name "zoo${i}" -e ZOO_ID=${i} wouterd/zookeeper
  else
    docker run -d --volumes-from ${conf_container} --name "zoo${i}" -e ZOO_ID=${i} wouterd/zookeeper
  fi
done

config=$(cat zoo.cfg.initial)

# Look up the zookeeper instance IPs and create the config file
for i in $(seq 1 $ZOOKEEPER_NODES) ; do
  container_name=zoo${i}
  container_ip=$(docker inspect --format '{{.NetworkSettings.IPAddress}}' ${container_name})
  line="server.${i}=${container_ip}:2888:3888"
  config="${config}"$'\n'"${line}"
done

# Write the config to the config container
echo "${config}" | docker run -i --rm --volumes-from ${conf_container} busybox sh -c 'cat > /zoo/conf/zoo.cfg'

zoo_links=''
zoo_connect=''
for i in $(seq 1 $ZOOKEEPER_NODES) ; do
  zoo_links="${zoo_links}--link zoo${i}:zoo${i} "
  zoo_connect="${zoo_connect}zoo${i}"
  if [ $i -lt ${ZOOKEEPER_NODES} ] ; then
    zoo_connect="${zoo_connect},"
  fi
done

# Start ZOOKEEPER_NODES apis
#for i in $(seq 1 $ZOOKEEPER_NODES) ; do
#  docker run -d ${zoo_links} -e ZOO=${zoo_connect} --name api${i} my-little-api 
#done
