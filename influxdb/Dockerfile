FROM influxdb:2.7

# Create and ensure data directory exists
RUN mkdir -p /var/lib/influxdb2

# Set correct volume for data persistence
VOLUME ["/var/lib/influxdb2"]

# Copy startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Default command
CMD [ "/run.sh" ]
