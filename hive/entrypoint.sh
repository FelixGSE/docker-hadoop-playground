#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

export HIVE_METASORE_DB_TYPE=${HIVE_METASORE_DB_TYPE:-postgres}

# Check whether required services are up and running
export SERVICE_TIMEOUT=${SERVICE_TIMEOUT:-60}

for temp_host in $(env | grep WAIT_FOR_SVC | sed s/.*=// | sed '/^$/d')
do

    echo "Attempting to call ${temp_host}"

    wait-for-it -t $SERVICE_TIMEOUT $temp_host

    echo "${temp_host} is up"

done

# 
case "$1" in

	"hive-metastore-svc")

		# Check if necessary hive directories exist in HDFS
		if $(hdfs dfs -test -d /tmp 2> /dev/null) && $(hdfs dfs -test -d /user/hive/warehouse 2> /dev/null); then

			echo "Required hive directories exist"

		else

			echo "At leas one required directories does not exist - initializing directories"
			hadoop fs -mkdir -p    /tmp
			hadoop fs -mkdir -p    /user/hive/warehouse
			hadoop fs -chmod g+w   /tmp
			hadoop fs -chmod g+w   /user/hive/warehouse

		fi

		# Init the metastore database
		if [[ -z $(schematool -info -dbType postgres 2> /dev/null | grep "Metastore schema version") ]]; then

			echo "initializing metastore schema"
			schematool -initSchema -verbose -dbType $HIVE_METASORE_DB_TYPE
		fi
		
		# Configure tez 
		if $(hdfs dfs -test -d /apps/tez/ 2> /dev/null ) && [[ ! -z "$(hadoop fs -ls /apps/tez 2> /dev/null)" ]]; then

			echo "Tez directory exists and is set up" 

		else

			echo "Setting up tez"
			hadoop fs -mkdir -p /apps
			hadoop fs -put /opt/tez /apps/

		fi  

		# start metastore
		hive --service metastore

	;;


	"hive-server")

		hiveserver2 --hiveconf hive.server2.enable.doAs=false

	;;

	* )
		
	   	echo "************************************************************"
		echo "Got invalid command: $1"
		echo "Valid commands are: [ hive-metastore-svc | hive-server]"
		echo "Shutting down!"
		echo "************************************************************"
		exit 1
	;;

esac
	