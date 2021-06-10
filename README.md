# Features

* New Cert Request via HTTP-01 Challenge
* Apply update to Kubernetes tls Secret, letsencrypt-tls-certs
* Check for Renewal 2 times a day
* act as a dummy web on port 3099, just in case you want to use it to test, 
* leaving port 80 unused because, HTTP-01 Challenge by certbot will need to occupie it.

# Usage

* check example folder

# Sample config on Envoy loadbalancer/http_ingress config

* you need to make sure cerbot is able to go in and out via port 80 when the HTTP-01 Challenge shoot up a temporary web service to host the token
```yaml
static_resources:
      listeners:
      - address:
          socket_address:
            address: 0.0.0.0
            port_value: 8080
        filter_chains:
        - filters:
          - name: envoy.filters.network.http_connection_manager
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
              codec_type: AUTO
              stat_prefix: ingress_http
              route_config:
                name: local_route
                virtual_hosts:
                - name: acmesolver
                  domains:
                  - "*"
                  routes:
                  - match:
                      prefix: "/.well-known/acme-challenge/"
                    route:
                      prefix_rewrite: "/.well-known/acme-challenge/"
                      cluster: acmesolver_cluster
                  - match:
                      prefix: "/"
                    route:
                      prefix_rewrite: "/"
                      cluster: empty_cluster
              http_filters:
              - name: envoy.filters.http.router
                typed_config: {}

...
...

clusters:
      - name: acmesolver_cluster
        connect_timeout: 0.25s
        type: strict_dns
        lb_policy: round_robin
        load_assignment:
          cluster_name: acmesolver_cluster
          endpoints:
          - lb_endpoints:
            - endpoint:
                address:
                  socket_address:
                    address: certbot #as yu can see both cluster are actually point to the same certbot container as below
                    port_value: 80   #here we show the content of http://xxx.example.com/.well-known/acme-challenge/<token>
      - name: empty_cluster
        connect_timeout: 0.25s
        type: strict_dns
        lb_policy: round_robin
        load_assignment:
          cluster_name: empty_cluster
          endpoints:
          - lb_endpoints:
            - endpoint:
                address:
                  socket_address:
                    address: certbot #as yu can see both cluster are actually point to the same certbot container as above
                    port_value: 3099 #but here we show the visitor with the content of http://xxx.example.com/www/index.html 
```