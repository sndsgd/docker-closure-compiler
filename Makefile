CWD := $(shell pwd)

# if no version is provided, `VERSION` is set in the `ensure-version` target
# the image will also be tagged `:latest` when the current version is built
VERSION ?=
FETCHED_VERSION ?=

NAME := sndsgd/closure-compiler
IMAGE_NAME ?= ghcr.io/$(NAME)
IMAGE := $(IMAGE_NAME):$(VERSION)
LATEST_IMAGE := $(IMAGE_NAME):latest

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[33m%s\033[0m~%s\n", $$1, $$2}' \
	| column -s "~" -t

VERSION_URL ?= https://github.com/google/closure-compiler/tags
.PHONY: ensure-version
ensure-version:
ifeq ($(VERSION),)
	$(info fetching latest version...)
	$(eval VERSION = $(shell curl -s $(VERSION_URL) | grep -Po '<a href=".*?/releases/tag/\Kv[^"]+' | sort | tail -n 1 ))
	@$(eval FETCHED_VERSION = $(VERSION))
endif
	@$(eval JARFILE_URL := $(VERSION_URL)$(VERSION)/closure-compiler-$(VERSION).jar)
	@$(eval IMAGE := $(IMAGE_NAME):$(VERSION))

IMAGE_ARGS ?= --quiet
.PHONY: image
image: ## Build the docker image
image: ensure-version
	$(info building image for closure compiler $(VERSION)...)
	@docker build \
	  $(IMAGE_ARGS) \
		--build-arg JARFILE_URL=$(JARFILE_URL) \
		--tag $(IMAGE) \
		$(CWD)
ifeq ($(VERSION),$(FETCHED_VERSION))
	@docker tag $(IMAGE) $(LATEST_IMAGE)
endif

.PHONY: test
test: ## Test the image
test: image
	$(info testing $(IMAGE)...)
	@docker run \
		--rm \
		-v $(CWD):$(CWD) \
		-w $(CWD) \
		$(IMAGE) \
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
ifeq ($(VERSION),$(FETCHED_VERSION))
	@docker push $(LATEST_IMAGE)
endif

.PHONY: push-cron
push-cron: ## Build and push an image if the version does not exist
push-cron: ensure-version
	@token_response="$$(curl --silent -f -lSL "https://ghcr.io/token?scope=repository:$(NAME):pull")"; \
	token="$$(echo "$$token_response" | jq -r .token)"; \
	json="$$(curl --silent -f -lSL -H "Authorization: Bearer $$token" https://ghcr.io/v2/$(NAME)/tags/list)"; \
	index="$$(echo "$$json" | jq '.tags | index("$(VERSION)")')"; \
	if [ "$$index" = "null" ]; then \
		make --no-print-directory push IMAGE_ARGS=--no-cache VERSION=$(VERSION) FETCHED_VERSION=$(VERSION); \
	else \
		echo "image for '$(VERSION)' already exists"; \
	fi

.PHONY: run-help
run-help: ## Run `closure-compiler --help`
run-help: image
	@docker run --rm $(IMAGE) --help

.PHONY: run-version
run-version: ## Run `closure-compiler --version`
run-version: image
	@docker run --rm $(IMAGE) --version

.DEFAULT_GOAL := help
