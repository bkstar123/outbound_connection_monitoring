#!/bin/bash

# Wrapper script to call outbound_connection_count.sh and do logging stuff
# author: Tuan Hoang
#
script_name=${0##*/}
function usage()
{
    echo "###Syntax: $script_name -t <threshold> - i <instance name>"
    echo "- You must specify instance name so that logs are written to separated folders for each instance"
    echo "- Without specifying -t <threshold>, the default will be 100"
    echo "###Threshold: when an instance has the number of outbound connections toward any destination reaches that threshold, the script will automatically take memory dump for that instance"
}
function die()
{
    echo "$1" && exit $2
}
while getopts ":t:i:h" opt; do
    case $opt in
        t) 
           threshold=$OPTARG
           ;;
        i) 
           instance=$OPTARG
           ;;
        h)
           usage
           exit 0
           ;;
        *) 
           die "Invalid option: -$OPTARG" 1 >&2
           ;;
    esac
done
shift $(( OPTIND - 1 ))

if [[ -z "$instance" ]]; then
    die "###Critical: You must specify instance name using the option -i, e.g: -i <instance name>" >&2 1
fi

if [[ -z "$threshold" ]]; then
    echo "###Info: without specifying option -t <threshold>, the script will set the default outbound connection count to 100 before triggering memory dump taking"
    threshold=100
fi

# Install net-tools if not exists
if ! command -v netstat &> /dev/null; then
    echo "###Info: netstat is not installed. Installing net-tools."
    apt-get update && apt-get install -y net-tools
fi

# Output dir is named after instance name
output_dir="outconn-logs-${instance}" 
current_hour=$(date +"%Y-%m-%d_%H")
output_file="$output_dir/outconn_stats_${current_hour}.log"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

while true; do
    # Check if it's a new hour
    current_hour=$(date +"%Y-%m-%d_%H")
    if [ "$current_hour" != "$previous_hour" ]; then
        # Rotate the file
        output_file="$output_dir/output_${current_hour}.log"
        previous_hour="$current_hour"
    fi
    
    # Your command to output to the file (example: echo "Some output" >> "$output_file")
  echo "Poll complete. Waiting for 10 seconds..."
    ./outbound_connection_count.sh $threshold >> "$output_file"

    # Wait for 10 seconds before the next run
    sleep 10
done

