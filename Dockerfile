FROM openresty/openresty:alpine

RUN apk --no-cache add curl \
    && echo "Pulling watchdog binary from Github." \
    && curl -sSL https://github.com/openfaas-incubator/of-watchdog/releases/download/0.2.5/of-watchdog > /usr/bin/fwatchdog \
    && chmod +x /usr/bin/fwatchdog \
    && apk del curl

# Add non root user
RUN addgroup -S app && adduser app -S -G app
RUN chown app /home/app

USER app

ENV PATH=$PATH:/home/app/.local/bin

WORKDIR /home/app/
COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN mkdir -p function

WORKDIR /home/app/function/
COPY function/handler.lua	.

WORKDIR /home/app/

USER root
ENV upstream_url="http://localhost:80"
ENV mode="http"

ENV fprocess="/etc/nginx/sbin/openresty"

HEALTHCHECK --interval=1s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]