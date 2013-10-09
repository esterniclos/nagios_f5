#!/bin/bash

#
# Returns if big ip is active or standby
#


service="BIGIPSTATUS"

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
	        "-H host\n" \
	        "-C community\n" \
                "-h this help\n" \
	        "\n" && exit $UNKNOWN
	}

# Loop through $@ to find flags
while getopts "H:C:h" FLAG; do
        case "${FLAG}" in
        H) # Warning value
            host="${OPTARG}" ;;
        C) # Community
           community="${OPTARG}" ;;
	h)
		HELP=1;;
        [:?]) # Print usage information
	    print_usage;;
	        esac
	done


# check arguments:
[[ ! $host ]] && print_usage 
[[ ! $community ]] && print_usage 


# log file:
printf "ARGS: $@\n" >> /var/log/nagios/nagios.log ;


# Get data:

DATA=$(snmpget -v 2c -c $community $host .1.3.6.1.4.1.3375.2.1.14.3.1.0)


# Set status & return code:
status="OK" && return_code=$OK

IS_ACTIVE=$(echo $DATA | grep -i "active" wc -l)
[[ $IS_ACTIVE -eq 0 ]] && status="UNKNOWN" && return_code=$UNKNOWN


#
# status
#
check_status=$(echo $service $status)

#
# Check info:
#
check_info=$(echo $host $DATA | cut -d' ' -f1,5)


#
# perfdata
perfdata=$(printf "ACTIVE=%d" $IS_ACTIVE)


#
# Result
#
printf "%s %s | %s\n" "$check_status" "$check_info" "$perfdata"

#
# Return code
#
exit $return_code