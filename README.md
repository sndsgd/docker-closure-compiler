# sndsgd/docker-closure-compiler

A [Closure Compiler](https://github.com/google/closure-compiler) docker image builder.


### Build

If you want to build the image locally, you can follow these steps:

1. Checkout this repo
1. Run `make image`


### Usage

_closure-compiler help_
```
docker run --rm ghcr.io/sndsgd/closure-compiler:v20230228 --help
```

_compile some javascript_
```
docker run --rm \
  -u $(id -u):$(id -g) \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  ghcr.io/sndsgd/closure-compiler:v20230228 \
  --js=file.js
```
