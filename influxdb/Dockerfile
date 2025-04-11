FROM influxdb:2.7

# Create necessary folders
RUN mkdir -p /data /var/lib/influxdb2

VOLUME ["/data", "/var/lib/influxdb2"]

COPY run.sh /
COPY index.js /
RUN chmod a+x /run.sh

