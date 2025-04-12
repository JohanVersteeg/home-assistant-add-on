#!/bin/bash

# Print some startup info
echo "Starting InfluxDB..."

# Start InfluxDB
influxd --bolt-path /var/lib/influxdb2/influxd.bolt \
        --engine-path /var/lib/influxdb2/engine