#!/bin/bash

# Print some startup info
echo "Starting InfluxDB..."

# Start 
influxd --bolt-path /data/influxdb/influxd.bolt --engine-path /data/influxdb/engine
