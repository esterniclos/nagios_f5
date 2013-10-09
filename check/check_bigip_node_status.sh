#!/bin/bash


service="BIGIPNODE"

# nagios plugins return values:
OK=0
WARNING=1
CRITICAL=2
UNKNOWN=3

# print usage information and exit
print_usage(){
        echo -e "\n" \
	        "usage: $0 -h host -p community -P Pool -n node \n" \
	        "\n" \
	        "-h host\n" \
	        "-p community\n" \
	        "-P pool\n" \
	        "-n node name in F5 \n"\
	        "-h           this help\n" \
	        "\n" && exit 1
	}

# Loop through $@ to find flags
while getopts "h:p:n:P:" FLAG; do
        case "${FLAG}" in
        h) # Warning value
            host="${OPTARG}" ;;
        p) # Community
           community="${OPTARG}" ;;
	P) # pool
   		POOL="${OPTARG}" ;;
	n) #NODE
           NODE="${OPTARG}" ;;
        h) # Print usage information
            HELP=1;;
        [:?]) # Print usage information
	    print_usage;;
	        esac
	done


[[ ! $host ]] && print_usage && exit $UNKNOWN
[[ ! $community ]] && print_usage && exit $UNKNOWN
[[ ! $NODE ]] && print_usage && exit $UNKNOWN
[[ ! $POOL ]] && print_usage && exit $UNKNOWN



printf "ARGS: $@\n" >> /var/log/nagios/nagios.log ;



# Get data:
# snmpwalk  -v 2c -c $community $host .1.3.6.1.4.1.3375.2.2.5.6.2.1.6 
DATA=$(snmpwalk  -v 2c -c $community $host .1.3.6.1.4.1.3375.2.2.5.6.2.1.6 | grep  -i "$POOL" | grep -i "$NODE" )

# echo $DATA

IS_ENABLED=$(echo $DATA | grep -i "enabled(" | wc -l)



# Set status & return code:
status="OK" && return_code=$OK

[[ $IS_ENABLED -eq 0 ]] && status="CRITICAL" && return_code=$CRITICAL




#
# status
#
check_status=$(echo $service $status)

#
# Check info:
#
check_info=$(echo $DATA | sed 's/"//g' | awk 'BEGIN {FS="."}; {print $2" "$3" "$4" "}')


#
# perfdata
perfdata=$(printf "ENABLED=%d" $IS_ENABLED)


#
# Result
#
printf "%s %s | %s\n" "$check_status" "$check_info" "$perfdata"

#
# Return code
#
exit $return_code