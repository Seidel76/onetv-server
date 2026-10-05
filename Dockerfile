# syntax=docker/dockerfile:1
# OneTV Server image built from a PUBLISHED RELEASE BINARY (no sources needed).
#
#   docker build --build-arg VERSION=1.0.0 -t onetv-server:1.0.0 .
#   docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 \
#       --build-arg VERSION=1.0.0 -t onetv-server:1.0.0 .
#
# The binary is verified against SHA256SUMS before it enters the image.

FROM alpine:3.20 AS fetch
ARG TARGETARCH
ARG TARGETVARIANT
ARG VERSION=latest
ARG BASE_URL=https://onetvconnect.com/server
RUN set -eu; \
    case "$TARGETARCH" in \
      amd64) f=onetv-server-linux-amd64 ;; \
      arm64) f=onetv-server-linux-arm64 ;; \
      arm)   f=onetv-server-linux-armv7 ;; \
      *) echo "unsupported arch $TARGETARCH" >&2; exit 1 ;; \
    esac; \
    v="$VERSION"; \
    if [ "$v" = latest ]; then v=$(wget -qO- "$BASE_URL/dl/latest/VERSION" | tr -d ' \r\n'); fi; \
    wget -qO /tmp/SHA256SUMS "$BASE_URL/dl/$v/SHA256SUMS"; \
    wget -qO /tmp/onetv-server "$BASE_URL/dl/$v/$f"; \
    want=$(awk -v f="$f" '$2==f{print $1}' /tmp/SHA256SUMS); \
    echo "$want  /tmp/onetv-server" | sha256sum -c -; \
    chmod 0755 /tmp/onetv-server; \
    mkdir -p /out/data /out/recordings; mv /tmp/onetv-server /out/onetv-server

FROM gcr.io/distroless/static-debian12
LABEL org.opencontainers.image.source="https://github.com/Seidel76/onetv-server" \
      org.opencontainers.image.title="OneTV Server" \
      org.opencontainers.image.url="https://onetvconnect.com/server"
COPY --from=fetch /out/onetv-server /usr/bin/onetv-server
COPY --from=fetch /out/data /data
COPY --from=fetch /out/recordings /recordings
ENV ONETV_DATA=/data \
    ONETV_WEB_PORT=47821 \
    ONETV_RECORDINGS=/recordings
EXPOSE 47820/tcp 47821/tcp 47823/udp 47824/udp 5353/udp
VOLUME ["/data", "/recordings"]
ENTRYPOINT ["/usr/bin/onetv-server"]
CMD ["serve", "--data", "/data", "--recordings", "/recordings"]
