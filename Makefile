# SPDX-FileCopyrightText: © 2025 Clifford Weinmann <https://www.cliffordweinmann.com/>
#
# SPDX-License-Identifier: BSD-2-Clause

# Configuration for podman/docker images
PLATFORMS := centos-stream8 centos-stream9 debian12 fedora40 fedora41 fedora42 sle15 ubuntu2204 ubuntu2404
REGISTRY := docker.io/cliffordw

# Configuration for KubeVirt containerDisk images
VMPLATFORMS := centos-stream9 centos-stream10 debian12 opensuse-15.6 ubuntu2404
VMREGISTRY := docker.io/cliffordw

# Use podman or docker?
ifeq ($(shell command -v podman 2> /dev/null),)
	CONTAINER_ENGINE := docker
else
	CONTAINER_ENGINE := podman
endif

# Decide on container engine to use
# PWD := $(shell pwd)
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

# Build podman/docker container images
.PHONY: build
build:
	@for platform in $(PLATFORMS); do \
		VER=v$$(awk 'BEGIN {FS="="} /ARG VERSION/ {print $$2}' podman/Containerfile.$$platform) ; \
		$(BUILD_CMD) -f podman/Containerfile.$$platform -t molecule-platform:$$platform.$$VER . ; \
		$(CONTAINER_ENGINE) tag molecule-platform:$$platform.$$VER molecule-platform:$$platform ; \
	done

# Tag podman/docker container images
.PHONY: tag
tag:
	@for platform in $(PLATFORMS); do \
		VER=v$$(awk 'BEGIN {FS="="} /ARG VERSION/ {print $$2}' podman/Containerfile.$$platform) ; \
		$(CONTAINER_ENGINE) tag molecule-platform:$$platform.$$VER $(REGISTRY)/molecule-platform:$$platform.$$VER ; \
		$(CONTAINER_ENGINE) tag molecule-platform:$$platform.$$VER $(REGISTRY)/molecule-platform:$$platform ; \
	done

# Push podman/docker container images
.PHONY: push
push: tag
	@for platform in $(PLATFORMS); do \
		VER=v$$(awk 'BEGIN {FS="="} /ARG VERSION/ {print $$2}' podman/Containerfile.$$platform) ; \
		$(CONTAINER_ENGINE) push $(REGISTRY)/molecule-platform:$$platform.$$VER ; \
		$(CONTAINER_ENGINE) push $(REGISTRY)/molecule-platform:$$platform ; \
	done

# Build KubeVirt containerDisk images
.PHONY: vmbuild
vmbuild:
	@for platform in $(VMPLATFORMS); do \
		VER=v$$(awk 'BEGIN {FS="="} /ARG VERSION/ {print $$2}' kubevirt/Containerfile.$$platform) ; \
		$(BUILD_CMD) -f kubevirt/Containerfile.$$platform -t kubevirt-containerdisk:$$platform.$$VER . ; \
		$(CONTAINER_ENGINE) tag kubevirt-containerdisk:$$platform.$$VER kubevirt-containerdisk:$$platform ; \
	done

# Tag KubeVirt containerDisk images
.PHONY: vmtag
vmtag:
	@for platform in $(VMPLATFORMS); do \
		VER=v$$(awk 'BEGIN {FS="="} /ARG VERSION/ {print $$2}' kubevirt/Containerfile.$$platform) ; \
		echo $(VMREGISTRY)/kubevirt-containerdisk:$$platform.$$VER ; \
		$(CONTAINER_ENGINE) tag kubevirt-containerdisk:$$platform.$$VER $(VMREGISTRY)/kubevirt-containerdisk:$$platform.$$VER ; \
		$(CONTAINER_ENGINE) tag kubevirt-containerdisk:$$platform.$$VER $(VMREGISTRY)/kubevirt-containerdisk:$$platform ; \
	done

# Push KubeVirt containerDisk images
.PHONY: vmpush
vmpush: vmtag
	@for platform in $(VMPLATFORMS); do \
		VER=v$$(awk 'BEGIN {FS="="} /ARG VERSION/ {print $$2}' kubevirt/Containerfile.$$platform) ; \
		echo $(VMREGISTRY)/kubevirt-containerdisk:$$platform.$$VER ; \
		$(CONTAINER_ENGINE) push $(VMREGISTRY)/kubevirt-containerdisk:$$platform.$$VER ; \
		$(CONTAINER_ENGINE) push $(VMREGISTRY)/kubevirt-containerdisk:$$platform ; \
	done
