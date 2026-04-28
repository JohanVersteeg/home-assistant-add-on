ARG BUILD_FROM=registry.gitlab.com/pro-chords/azure-functions:latest
FROM $BUILD_FROM

RUN apt-get update \
    && apt-get install -y --no-install-recommends jq \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
