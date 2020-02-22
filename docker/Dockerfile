FROM alpine

RUN apk add --update curl sed tar \
&&  rm -rf /var/cache/apk/*

VOLUME /spk
COPY . /app/
ENV UID=1000
ENTRYPOINT [ "/app/create_spk.sh" ]
