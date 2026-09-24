FROM ubuntu:22.04
COPY script.sh /usr/local/bin/script.sh
WORKDIR /var/www
RUN apt-get update && apt-get install -y --no-install-recommends python3 \
    && rm -rf /var/lib/apt/lists/* \
    && chmod +x /usr/local/bin/script.sh

CMD ["/bin/bash", "-c", "/usr/local/bin/script.sh & exec python3 -m http.server 8080"]
