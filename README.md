# sndsgd/docker-closure-compiler

A [Closure Compiler](https://github.com/google/closure-compiler) docker image builder.

### Usage

_closure-compiler help_
```
docker run --rm ghcr.io/sndsgd/closure-compiler:latest --help
```

_compile some javascript_
```
docker run --rm \
  -v "$(pwd)":"$(pwd)" \
  -w "$(pwd)" \
  ghcr.io/sndsgd/closure-compiler:latest \
  --js="$(pwd)/path/to/src/**.js" \
  --js="$(pwd)/path/to/entrypoint.js"
```

### Build

If you want to build the image locally, you can follow these steps:

1. Checkout this repo
1. Run `make image`

