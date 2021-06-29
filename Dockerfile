FROM alpine:3.13

ENV MINIO_UPDATE off
ENV MINIO_ACCESS_KEY_FILE=access_key \
    MINIO_SECRET_KEY_FILE=secret_key \
    MINIO_KMS_MASTER_KEY_FILE=kms_master_key \
    MINIO_SSE_MASTER_KEY_FILE=sse_master_key

RUN \
    ARCH=$(apk --print-arch); \
    apk add --no-progress --no-cache wget; \
    if [[ "$ARCH" == "x86_64" ]]; then DOWNLOAD_URL="https://dl.min.io/server/minio/release/linux-amd64/minio"; \
    elif [[ "$ARCH" == "armv7" ]]; then DOWNLOAD_URL="https://dl.min.io/server/minio/release/linux-arm/minio"; \
    elif [[ "$ARCH" == "aarch64" ]]; then DOWNLOAD_URL="https://dl.min.io/server/minio/release/linux-arm64/minio"; \
    fi; \
    wget $DOWNLOAD_URL -nv -O /usr/bin/minio; \
    wget $DOWNLOAD_URL.sha256sum -nv -O /usr/bin/minio.sha256sum; \
    chmod +x /usr/bin/minio; \
    wget https://github.com/minio/minio/raw/master/dockerscripts/docker-entrypoint.sh -nv -O /usr/bin/docker-entrypoint.sh; \
    chmod +x /usr/bin/docker-entrypoint.sh;

RUN \
    echo "Checking signature of downloaded binary:"; \
    echo "$(awk '{print $1}' /usr/bin/minio.sha256sum)  /usr/bin/minio" > /tmp/checksum; \
    sha256sum -c /tmp/checksum


EXPOSE 9000

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

VOLUME ["/data"]

CMD ["minio"]
