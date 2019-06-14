# This will reliably return the short SHA1 of HEAD or, if the working directory
# is dirty, will return that + "-dirty"
GIT_VERSION = $(shell git describe --always --abbrev=7 --dirty --match=NeVeRmAtCh)

BASE_IMAGE_NAME = go-dind

ifdef DOCKER_REGISTRY
	DOCKER_REGISTRY := $(DOCKER_REGISTRY)/
endif

ifdef DOCKER_ORG
	DOCKER_ORG := $(DOCKER_ORG)/
endif

DOCKER_IMAGE_PREFIX := $(DOCKER_REGISTRY)$(DOCKER_ORG)

ifdef VERSION
	MUTABLE_DOCKER_TAG := latest
else
	VERSION            := $(GIT_VERSION)
	MUTABLE_DOCKER_TAG := edge
endif

IMMUTABLE_DOCKER_TAG := $(VERSION)

.PHONY: check-docker
check-docker:
	@if [ -z $$(which docker) ]; then \
		echo "Missing \`docker\` client which is required for development"; \
		exit 2; \
	fi

.PHONY: check-image
check-image:
ifeq ($(DOCKER_IMAGE_PREFIX),"")
	$(error DOCKER_REGISTRY and/or DOCKER_ORG must be set in the env to push images)
endif

.PHONY: build
build: check-docker
	docker build -t $(DOCKER_IMAGE_PREFIX)$(BASE_IMAGE_NAME):$(IMMUTABLE_DOCKER_TAG) .
	docker tag $(DOCKER_IMAGE_PREFIX)$(BASE_IMAGE_NAME):$(IMMUTABLE_DOCKER_TAG) \
		$(DOCKER_IMAGE_PREFIX)$(BASE_IMAGE_NAME):$(MUTABLE_DOCKER_TAG)

.PHONY: push
push: check-docker check-image build
	docker push $(DOCKER_IMAGE_PREFIX)$(BASE_IMAGE_NAME):$(IMMUTABLE_DOCKER_TAG)
	docker push $(DOCKER_IMAGE_PREFIX)$(BASE_IMAGE_NAME):$(MUTABLE_DOCKER_TAG)

