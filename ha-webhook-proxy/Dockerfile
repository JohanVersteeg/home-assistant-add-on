FROM nginx:stable-alpine

RUN apk add --no-cache jq \
    && rm -f /etc/nginx/conf.d/default.conf

COPY nginx.conf.tpl /etc/nginx/nginx.conf.tpl
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
