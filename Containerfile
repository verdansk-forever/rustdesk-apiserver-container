FROM ghcr.io/kingmo888/rustdesk-api-server

COPY --chown=0:0 --chmod=0755 run0.sh /rustdesk-api-server/run0.sh

RUN apk add curl

ENTRYPOINT [ "/rustdesk-api-server/run0.sh" ]
