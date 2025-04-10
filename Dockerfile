FROM        golang:1.21.5-alpine3.17 AS BUILD_IMAGE
RUN         apk add --update --no-cache -t build-deps curl gcc libc-dev libgcc
WORKDIR     /go/src/github.com/adnanh/webhook
COPY        webhook.version .
RUN         curl -#L -o webhook.tar.gz https://api.github.com/repos/adnanh/webhook/tarball/$(cat webhook.version) && \
            tar -xzf webhook.tar.gz --strip 1 &&  \
            go get -d && \
            go build -ldflags="-s -w" -o /usr/local/bin/webhook

FROM        alpine:3.21.2
RUN         apk add --update --no-cache \
                bash \
                ca-certificates \
                curl \
                jq \
                ntfy \
                python3 \
                py3-pip \
                tini \
                tzdata
RUN         python3 -m venv /venv && \
                /venv/bin/pip install --no-cache-dir --upgrade pip apprise
ENV         PATH="/venv/bin:$PATH"
ENV         VIRTUAL_ENV="/venv"
COPY        --from=BUILD_IMAGE /usr/local/bin/webhook /usr/local/bin/webhook
COPY        entrypoint.sh /usr/local/bin/entrypoint.sh
RUN         chmod +x /usr/local/bin/entrypoint.sh
WORKDIR     /config
EXPOSE      9000
ENTRYPOINT  ["/usr/local/bin/entrypoint.sh"]
