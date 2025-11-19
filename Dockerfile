FROM debian:trixie-slim AS build

RUN apt-get update && apt-get install -y \
  build-essential curl gcc git gnupg nodejs openjdk-21-jdk-headless python3 zip

WORKDIR /opt
RUN curl -fsSL https://github.com/bazelbuild/bazelisk/releases/download/v1.27.0/bazelisk-amd64.deb -o /tmp/bazelisk-amd64.deb \
  && dpkg -i /tmp/bazelisk-amd64.deb

ARG VERSION
RUN git clone --depth=1 --branch ${VERSION} https://github.com/google/closure-compiler.git

WORKDIR /opt/closure-compiler

# use the tag from git (as opposed to ${VERSION}) to ensure we have the correct version
RUN GIT_TAG=$(git describe --tags --abbrev=0) && \
  bazelisk build --define=COMPILER_VERSION=$GIT_TAG --verbose_failures //:compiler_uberjar_deploy.jar

# runtime image
FROM debian:trixie-slim
LABEL maintainer=sndsgd

RUN apt-get update && apt-get install --yes --no-install-recommends openjdk-21-jre-headless
COPY --from=build /opt/closure-compiler/bazel-bin/compiler_uberjar_deploy.jar /opt/closure-compiler.jar
ENTRYPOINT ["java", "-jar", "/opt/closure-compiler.jar"]
