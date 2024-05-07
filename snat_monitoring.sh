#!/bin/bash

# Output dir is named after instance name
output_dir="outconn-logs-${WEBSITE_INSTANCE_ID}" 
current_hour=$(date +"%Y-%m-%d_%H")
output_file="$output_dir/outconn_stats_${current_hour}.log"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

threshold=100

while getopts ":t:" opt; do
    case $opt in
        t) threshold=${OPTARG};;
        *) die "Invalid option: -$OPTARG" >&2;;
    esac
done
shift $(( OPTIND - 1 ))

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

