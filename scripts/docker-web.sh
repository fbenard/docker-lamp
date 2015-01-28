#!/bin/bash

#

flags="--rm -it --tty --entrypoint=\"bash\""
image="fbenard/docker-web"
name=
ports=


# Define default services / ports

declare -a SERVICES=("apache" "elastic-search" "mongodb" "mysql" "rabbitmq" "redis")
declare -a PORTS_HOST=()
declare -a PORTS_CONTAINER=()


# Parse -b option

while getopts “b:di:n:” OPTION
do
	case $OPTION in
	b)
		# Reset default services

		declare -a SERVICES=()

		
		# Explode services

		IFS='|' read -a services <<< "$OPTARG"

		
		# Parse each service

		for service in "${services[@]}"
		do
			# Explode service name and port

			IFS=':' read -a service <<< "$service"

			
			# Store the service name

			SERVICES+=(${service[0]})

			
			# Store the service port

			if [ -n "${service[1]}" ]
			then
				PORTS_HOST+=(${service[1]})
			else
				PORTS_HOST+=("0")
			fi
		done
	;;
	d)
		flags="-d"
	;;
	i)
		image=$OPTARG
	;;
	n)
		name="--name $OPTARG"
	;;
	esac
done


# Parse default services

for index in "${!SERVICES[@]}"
do
	# Define the default port

	port=

	if [ "${SERVICES[index]}" == "apache" ]
	then
		port=80
	elif [ "${SERVICES[index]}" == "mongodb" ]
	then
		port=27017
	elif [ "${SERVICES[index]}" == "elastic-search" ]
	then
		port=9200
	elif [ "${SERVICES[index]}" == "mysql" ]
	then
		port=3306
	elif [ "${SERVICES[index]}" == "rabbitmq" ]
	then
		port=15672
	elif [ "${SERVICES[index]}" == "redis" ]
	then
		port=6379
	fi

	
	# Store the port

	PORTS_CONTAINER+=($port)

	if [ "${PORTS_HOST[index]}" == "0" ]
	then
		PORTS_HOST[index]=$port
	fi		
done


# Build the ports command line

for index in "${!SERVICES[@]}"
do
	ports="$p -p ${PORTS_HOST[index]}:${PORTS_CONTAINER[index]}"
done


# Init boot2docker

VBoxManage discardstate boot2docker-vm
boot2docker up
`boot2docker shellinit`


# Run the image

docker run $flags $ports $name -v `pwd`:/var/www/app $image
