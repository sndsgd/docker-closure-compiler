CWD := $(shell pwd)

VERSION_URL ?= https://repo1.maven.org/maven2/com/google/javascript/closure-compiler/
VERSION_PATTERN ?= '(?<=>)[^/]+(?=/)'
VERSION ?=
ifndef (VERSION)
	VERSION = $(shell curl -s $(VERSION_URL) | grep '<a href="v' | sort | tail -n 1 | grep -Po $(VERSION_PATTERN))
endif
JARFILE_URL = $(VERSION_URL)$(VERSION)/closure-compiler-$(VERSION).jar

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[33m%s\033[0m~%s\n", $$1, $$2}' \
	| column -s "~" -t

IMAGE_NAME ?= sndsgd/closure-compiler
IMAGE := $(IMAGE_NAME):$(VERSION)
IMAGE_ARGS ?= --quiet
.PHONY: image
image: ## Build the docker image
	@echo "building image..."
	@docker build \
	  $(IMAGE_ARGS) \
		--build-arg JARFILE_URL=$(JARFILE_URL) \
		--tag $(IMAGE_NAME):latest \
		--tag $(IMAGE) \
		$(CWD)

.PHONY: test
test: ## Test the image
test: image
	@docker run \
		--rm \
		-v $(CWD):$(CWD) \
		-w $(CWD) \
		$(IMAGE_NAME) \
		--warning_level=VERBOSE \
		--summary_detail_level=10 \
		--language_out=ECMASCRIPT6_STRICT \
		--compilation_level=ADVANCED \
		--isolation_mode=IIFE \
		--use_types_for_optimization=true \
		--formatting=PRETTY_PRINT \
		--js="tests/*.js"

.PHONY: push
push: ## Push the docker image
push: test
	@docker push $(IMAGE)
	@docker push $(IMAGE_NAME):latest

IMAGE_CHECK_URL = https://index.docker.io/v1/repositories/$(IMAGE_NAME)/tags/$(VERSION)
.PHONY: push-cron
push-cron: ## Push an image if the version does not exist
	curl --silent -f -lSL $(IMAGE_CHECK_URL) > /dev/null \
	  || make --no-print-directory push IMAGE_ARGS=--no-cache

.PHONY: run-help
run-help: ## Run `closure-compiler --help`
run-help: image
	@docker run --rm $(IMAGE_NAME) --help

.PHONY: run-version
run-version: ## Run `closure-compiler --version`
run-version: image
	@docker run --rm $(IMAGE_NAME) --version

.DEFAULT_GOAL := help
