#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Variables for hadoop runtime
export MULTIHOMED_NETWORK=${MULTIHOMED_NETWORK:-1}
export CLUSTER_NAME=${CLUSTER_NAME:-hadoop-playground}
export NAMENODE_DIR=${NAMENODE_DIR:-$HADOOP_RUNTIME_HOME/dfs/name}
export DATANODE_DIR=${DATANODE_DIR:-$HADOOP_RUNTIME_HOME/dfs/data}

# Check required services are up and running
export SERVICE_TIMEOUT=${SERVICE_TIMEOUT:-60}

for temp_host in $(env | grep WAIT_FOR_SVC | sed s/.*=// | sed '/^$/d')
do

    echo "Attempting to call ${temp_host}"

    wait-for-it -t $SERVICE_TIMEOUT $temp_host

    echo "${temp_host} is up"

done

# Launch services according to cmd
case "$1" in

	"namenode")
		
	mkdir -p $NAMENODE_DIR

	if [[ -z "$(ls -A $NAMENODE_DIR)" ]]; then

		echo "Formating namenode"
	  	hdfs --config $HADOOP_CONF_DIR namenode -format $CLUSTER_NAME 
	fi

	hdfs --config $HADOOP_CONF_DIR namenode 
		
	;;

	"datanode")
	
	mkdir -p $DATANODE_DIR
	
	hdfs --config $HADOOP_CONF_DIR datanode
	
	;;

	"resourcemanager")

	yarn --config $HADOOP_CONF_DIR resourcemanager

	;;

	"nodemanager")

	yarn --config $HADOOP_CONF_DIR nodemanager

	;;
	
	* )

	echo "************************************************************"
	echo "Invalid command: $1									  "
	echo "Valid commands: [ namenode | datanode |					  "
	echo "					resourcemanager | nodemanager ]			  "
	echo "Shutting down!											  "
	echo "************************************************************"
	
	exit 1

esac
   