# sndsgd/docker-closure-compiler

A [Closure Compiler](https://github.com/google/closure-compiler) docker image builder.


### Build

If you want to build the image locally, you can follow these steps:

1. Checkout this repo
1. Run `make build-image`


### Usage

_closure-compiler help_

        docker run --rm sndsgd/closure-compiler --help


_compile some javascript_

        docker run --rm -v /path/to/js:/js -w /js sndsgd/closure-compiler --js=file.js
