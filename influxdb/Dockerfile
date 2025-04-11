FROM influxdb:2.7

# Create necessary folders
RUN mkdir -p /data /var/lib/influxdb2

# Copy run.sh and set permissions
COPY run.sh /run.sh
RUN chmod +x /run.sh

VOLUME ["/data", "/var/lib/influxdb2"]

# Set default working directory
WORKDIR /var/lib/influxdb2

CMD ["/run.sh"]
