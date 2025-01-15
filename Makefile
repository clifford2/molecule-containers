# Build with: make TARGETARCH=(arm64v8|amd64|ppc64le) build-package

# Use podman or docker?
ifeq ($(shell command -v podman 2> /dev/null),)
	CONTAINER_ENGINE := docker
else
	CONTAINER_ENGINE := podman
endif

# Get current image version
PWD := $(shell pwd)
ifeq ($(CONTAINER_ENGINE),podman)
	BUILDARCH := $(shell podman version --format '{{.Client.OsArch}}' | cut -d/ -f2)
	BUILD_NOLOAD := podman build
	BUILD_CMD := $(BUILD_NOLOAD)
else
	BUILDARCH := $(shell docker version --format '{{.Client.Arch}}')
	BUILD_NOLOAD := docker buildx build
	BUILD_CMD := $(BUILD_NOLOAD) --load
endif


.PHONY: all
all: build

.PHONY: about
about:
	@echo "We're using $(CONTAINER_ENGINE) on $(BUILDARCH)"

.PHONY: build
build:
	@for platform in centos-stream8 centos-stream9 debian12 fedora42 sle15 ubuntu2204 ubuntu2404; do \
		VER=v$$(awk 'BEGIN {FS="="} /ARG VERSION/ {print $$2}' Containerfile.$$platform) ; \
		$(BUILD_CMD) -f Containerfile.$$platform -t molecule-platform:$$platform.$$VER . ; \
		$(CONTAINER_ENGINE) tag molecule-platform:$$platform.$$VER molecule-platform:$$platform ; \
	done

.PHONY: push
push:
	@for platform in centos-stream8 centos-stream9 debian12 fedora42 sle15 ubuntu2204 ubuntu2404; do \
		VER=v$$(awk 'BEGIN {FS="="} /ARG VERSION/ {print $$2}' Containerfile.$$platform) ; \
		$(CONTAINER_ENGINE) tag molecule-platform:$$platform.$$VER docker.io/cliffordw/molecule-platform:$$platform.$$VER ; \
		$(CONTAINER_ENGINE) tag molecule-platform:$$platform.$$VER docker.io/cliffordw/molecule-platform:$$platform ; \
		$(CONTAINER_ENGINE) push docker.io/cliffordw/molecule-platform:$$platform.$$VER ; \
		$(CONTAINER_ENGINE) push docker.io/cliffordw/molecule-platform:$$platform ; \
	done
