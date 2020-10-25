FROM alpine:3.12
LABEL maintainer sndsgd

ARG JARFILE_URL

RUN apk add --update --no-cache curl openjdk11-jre \
    && curl ${JARFILE_URL} -o /opt/closure-compiler.jar \
    && chmod 0755 /opt/closure-compiler.jar \
    && echo -e "#!/bin/sh -e\nexec java -jar /opt/closure-compiler.jar \$@" > /usr/bin/closure-compiler \
    && chmod +x /usr/bin/closure-compiler

ENTRYPOINT ["/usr/bin/closure-compiler"]
