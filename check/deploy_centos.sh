#!/bin/bash

#
# Deploy plugin in plugin directory
#

# NAGIOSDIR=/usr/lib64/nagios/plugins
NAGIOSDIR=/tmp




print_usage(){
        echo -e "\n" \
                "usage: $0 check_list " \n
                "\n" && exit 1
        }



#
# Main
# 

# Test arguments
[[ $# -eq 0 ]] && print_usage

## Copy scripts
args=("$@")

# Works for real files:
for ((i=0; i < $#; i++)) 
do
    f=${args[$i]}
   [[ -e $f ]] && cp -v $f $NAGIOSDIR/$f ;
done

