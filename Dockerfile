FROM alpine

RUN apk add --update \
        curl \
        sed \
        tar \
    && rm -rf /var/cache/apk/*

RUN mkdir -p /opt
COPY . /opt/gitea-spk/

VOLUME /data


WORKDIR /opt/gitea-spk

ENTRYPOINT [ "/opt/gitea-spk/entrypoint" ]

CMD ["gitea"]
