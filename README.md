# Outbound Connection Monitoring

A collection of shell scripts for monitoring outbound connections in .NET Core applications running on Linux environments, with a focus on SNAT (Source Network Address Translation) connection monitoring and automatic diagnostic data collection.

## Features

- Monitor outbound network connections excluding specific incoming ports (80, 443, 2222)
- Automatic memory dump and profiler trace collection when connection thresholds are exceeded
- Support for both IPv4 and IPv6 connections
- Configurable monitoring frequency and connection thresholds
- Automatic upload of diagnostic data to Azure Blob Storage
- Detailed connection statistics with state information
- Robust error handling and retry mechanisms

## Script

### snat_connection_monitoring.sh
The main script that provides comprehensive monitoring capabilities including:
- Memory dump collection
- Profiler trace collection
- Configurable thresholds and polling intervals
- Automatic upload to Azure Blob Storage
- Retry mechanism for failed uploads

Usage:
```bash
./snat_connection_monitoring.sh -t <threshold> -f <interval> [enable-dump|enable-trace|enable-dump-trace]
```

Options:
- `-t <threshold>`: Set connection threshold (default: 100)
- `-f <interval>`: Set polling frequency in seconds (default: 10)
- `enable-dump`: Enable memory dump collection
- `enable-trace`: Enable profiler trace collection
- `enable-dump-trace`: Enable both memory dump and trace collection


## Prerequisites

- Linux environment
- .NET Core application running
- net-tools package (installed automatically if missing)
- Azure Blob Storage container with SAS URL for uploading diagnostics
- Environment variables:
  - COMPUTERNAME
  - DIAGNOSTICS_AZUREBLOBCONTAINERSASURL

## Output

The scripts generate detailed logs including:
- Connection statistics
- Memory dumps (.dmp files)
- Profiler traces (.nettrace files)
- Timestamps for all operations
- Upload status and retry information

## Log Directory Structure

Logs are organized by instance name and timestamp:
```
outconn-logs-{instance}/
└── outbound_conns_stats_{YYYY-MM-DD_HH}.log
```

## Error Handling

- Automatic retry mechanism for failed uploads (up to 5 attempts)
- Lock file mechanism to prevent duplicate diagnostic collection
- Graceful teardown of processes
- Detailed error logging

## Authors

- Mainul Hossain (Main integration)
- Tuan Hoang (SNAT monitoring)
- Ander Wahlqvist (Original connection monitoring)

## Last Updated

February 12, 2025

## License

This project is proprietary software. All rights reserved.