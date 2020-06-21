FROM alpine:3.12
LABEL maintainer sndsgd

ARG DOWNLOAD_URL=https://dl.google.com/closure-compiler/compiler-latest.zip

COPY VERSION /opt/VERSION

RUN apk add --no-cache --virtual dependencies curl unzip \
    && apk add --no-cache --update openjdk11-jre \
    && curl $DOWNLOAD_URL -o /tmp/closure-compiler.zip \
    && unzip -d /tmp /tmp/closure-compiler.zip closure-compiler-*.jar \
    && apk del --purge dependencies \
    && mv /tmp/closure-compiler-*.jar /opt/closure-compiler.jar \
    && rm /tmp/closure-compiler.zip \
    && echo -e "#!/bin/sh -e\nexec java -jar /opt/closure-compiler.jar \$@" > /usr/bin/closure-compiler \
    && cat /usr/bin/closure-compiler \
    && chmod +x /usr/bin/closure-compiler

ENTRYPOINT ["/usr/bin/closure-compiler"]
