worker_processes 1;
pid /tmp/nginx.pid;

events {
    worker_connections 256;
}

http {
    server_tokens off;

    # Never log the URI: it contains the webhook ID, which is the secret.
    # Request errors (rate limit, upstream down) include the URI, so only log crit and
    # rely on $status / $upstream_status in the access log instead.
    log_format webhook '$remote_addr [$time_local] "$request_method" $status $body_bytes_sent upstream=$upstream_status';
    access_log /dev/stdout webhook;
    error_log /dev/stderr crit;

    limit_req_zone $binary_remote_addr zone=webhooks:1m rate=__RATE__r/m;
    limit_req_status 429;

    client_max_body_size __MAX_BODY__k;

    # Real client IP from Cloudflare, only trusted from cloudflared (trusted_proxies)
    include /etc/nginx/real_ip.conf;

    map $webhook_id $webhook_allowed {
        default 0;
        include /etc/nginx/allowed_webhooks.conf;
    }

    server {
        listen 8080;

        location ~ ^/api/webhook/(?<webhook_id>[A-Za-z0-9_-]+)$ {
            if ($webhook_allowed = 0) {
                return 404;
            }

            limit_except POST {
                deny all;
            }

            limit_req zone=webhooks burst=10 nodelay;

            proxy_pass __HA_URL__;
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        location / {
            return 404;
        }
    }
}
