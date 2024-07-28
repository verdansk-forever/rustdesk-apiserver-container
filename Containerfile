FROM docker.io/library/golang:latest AS build

COPY 0000-patch.patch /0000-patch.patch

RUN set -e; \
	git clone --depth 1 https://github.com/xiaoyi510/rustdesk-api-server; \
	cd rustdesk-api-server; \
	git apply /0000-patch.patch; \
	export CGO_ENABLED=1; \
	go build \
	-tags netgo,osusergo,static \
	-ldflags '-linkmode external -extldflags "-fno-PIC -static -s"' \
	-o rustdesk-api-server

FROM gcr.io/distroless/static

COPY --chown=0:0 --chmod=0700 --from=build \
	/go/rustdesk-api-server/rustdesk-api-server \
	/bin/rustdesk-api-server

ENTRYPOINT [ "/bin/rustdesk-api-server" ]
