#!/bin/bash
 
# Script for polling current connections, excluding incoming connections
# on ports 80, 443, and 2222, but including outgoing connections to those ports.
# This script focuses on readability, correct data presentation, and IPv6 support.
 
# Check if netstat is installed
# author: Ander Wahlqvist
# Modified by Tuan Hoang
#
echo "Polling current connections, specifically excluding incoming connections on ports 80, 443, and 2222..."
echo "--------------------------------------------------------------------------------"
printf "%-45s %-8s %s\n" "Remote Address:Port" "Total" "States (Count)"
echo "--------------------------------------------------------------------------------"
export threshold=$1
# Collect connections, focusing on correctly excluding specified incoming ports, and aggregate by remote host and state
netstat -natp | awk '/ESTABLISHED|TIME_WAIT|CLOSE_WAIT|FIN_WAIT/ {
    split($4, laddr, ":"); # Local address and port
    split($5, faddr, ":"); # Foreign address and port
    # Handle IPv6 addresses which include more colons
    if (length(laddr) > 2) {
        localPort=laddr[length(laddr)]; # Last element for IPv6
    } else {
        localPort=laddr[2]; # Second element for IPv4
    }
    if (length(faddr) > 2) {
        foreignPort=faddr[length(faddr)]; # Last element for IPv6
    } else {
        foreignPort=faddr[2]; # Second element for IPv4
    }
    # Exclude connections where the local machine is listening on 80, 443, or 2222
    if (localPort !~ /^(80|443|2222)$/)
        print $5, $6
 }' | sort | uniq -c | sort -rn | \
 awk '{
    # Aggregate counts by Remote Address:Port and state, total per Remote Address:Port, and list of states with counts
    remote_addr_state[$2 " " $3]+=$1;
    remote_addr_total[$2]+=$1;
    states[$2]=states[$2] " " $3 "(" $1 ")";
 }
 END {
     max_connection_count=0
     for (remote_addr in remote_addr_total) {
        if (remote_addr_total[remote_addr]>max_connection_count) {
            max_connection_count=remote_addr_total[remote_addr]
        }
        printf "%-45s %-8d %s\n", remote_addr, remote_addr_total[remote_addr], states[remote_addr]
     }
     if (max_connection_count>ENVIRON["threshold"]) {
          if (getline < "dump_taken.lock" < 0) {
              system("touch dump_taken.lock && echo 1 >> dump_taken.lock")
              print "Taking memory dump..."
              system("nohup /tools/dotnet-dump collect -p $(/tools/dotnet-dump ps | grep /usr/share/dotnet/dotnet | grep -v grep | tr -s \" \" | cut -d\" \" -f2) &")
          }
     }
 }' | sort -k2,2nr
echo "--------------------------------------------------------------------------------"
echo "Current timestamp: $(date '+%Y-%m-%d %H:%M:%S')"