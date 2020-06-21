CWD := $(shell pwd)
IMAGE_NAME ?= sndsgd/closure-compiler

# we don't know the version until we create an image and run `--version`
# so we'll create a temp image to check the version, and then use the
# result to tag the resulting image
TEMP_IMAGE_TAG := $(shell date +"%y-%m-%d-%H-%M-%S")
TEMP_IMAGE := $(IMAGE_NAME):$(TEMP_IMAGE_TAG)

.PHONY: build-temp-image
build-temp-image:
	docker build --no-cache --tag $(TEMP_IMAGE) $(CWD)

.PHONY: build
build: build-temp-image
	$(eval VERSION_INFO := $(shell docker run --rm $(TEMP_IMAGE) --version))
	$(eval VERSION := $(shell echo "$(VERSION_INFO)" | sed 's/.*Version: \([^ ]*\).*/\1/'))
	echo $(VERSION) > VERSION
	docker image rm $(TEMP_IMAGE)
	docker build --tag $(IMAGE_NAME):$(VERSION) --tag $(IMAGE_NAME):latest $(CWD)

.DEFAULT_GOAL := build
