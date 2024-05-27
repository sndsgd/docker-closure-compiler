FROM alpine:3.20
LABEL maintainer sndsgd

ARG JARFILE_URL

RUN apk add --update --no-cache curl openjdk11-jre \
    && curl ${JARFILE_URL} -o /opt/closure-compiler.jar \
    && chmod 0755 /opt/closure-compiler.jar \
    && echo -e "#!/bin/sh -e\nexec java -jar /opt/closure-compiler.jar \$@" > /usr/local/bin/closure-compiler \
    && chmod +x /usr/local/bin/closure-compiler

ENTRYPOINT ["/usr/local/bin/closure-compiler"]
