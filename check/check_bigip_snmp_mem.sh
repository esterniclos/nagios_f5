#!/bin/bash


service="BIGIPMEM"

# nagios plugins return values:
OK=0
WARNING=1
CRITICAL=2
UNKNOWN=3

# print usage information and exit
print_usage(){
        echo -e "\n" \
	        "usage: ./check_tmm_memory -w 80 -c 95 \n" \
	        "\n" \
	        "-h percentage   host\n" \
	    "-p percentage   community\n" \
	    "-w percentage   warning value\n" \
	        "-c percentage   critical value\n" \
	        "-h           this help\n" \
	        "\n" && exit 1
	}

# Loop through $@ to find flags
while getopts "h:p:w:c:" FLAG; do
        case "${FLAG}" in
        h) # Warning value
            host="${OPTARG}" ;;
p) # Community
           community="${OPTARG}" ;;
w) # Warning value
            WARNING_VALUE="${OPTARG}" ;;
        c) # Critical value
            CRITICAL_VALUE="${OPTARG}" ;;
        h) # Print usage information
            HELP=1;;
        [:?]) # Print usage information
	            print_usage;;
	        esac
	done

[[ ! $WARNING_VALUE ]] && print_usage && exit $UNKNOWN
[[ ! $CRITICAL_VALUE ]] && print_usage && exit $UNKNOWN





# Get data:

used_mem=$(snmpget -v2c -c $community $host sysGlobalTmmStatMemoryUsedKb.0 | awk '{print $4/1024}')
available_mem=$(snmpget -v2c -c $community $host sysGlobalTmmStatMemoryTotalKb.0 | awk '{print $4/1024}')
used_perc=$(echo "scale=2; $used_mem*100/$available_mem" | bc )
used_perc_round=$(echo "scale=0; $used_mem*100/$available_mem" | bc )

# Debug:
# echo  used_perc=$used_perc used_mem=$used_mem available_mem=$available_mem
# printf "used_perc=%f used_mem=%f available_mem=%f\n" $used_perc $used_mem $available_mem

# Set status & return code:
status="OK" && return_code=$OK
[[ $used_perc_round -ge $WARNING_VALUE ]] && status="WARNING" && return_code=$WARNING
[[ $used_perc_round -ge $CRITICAL_VALUE ]] && status="CRITICAL" && return_code=$CRITICAL




#
# status
#
check_status=$(echo $service $status)

#
# Check info:
#
check_info=$(printf "Used_percentage=%s%% Used=%sM Available=%sM" $used_perc $used_mem  $available_mem)

#
# perfdata
perfdata=$(printf "Used_percentage=%s%% Used=%sM Available=%sM" $used_perc $used_mem  $available_mem)


#
# Result
#
printf "%s %s | %s\n" "$check_status" "$check_info" "$perfdata"

#
# Return code
#
exit $return_code