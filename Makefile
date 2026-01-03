# SPDX-FileCopyrightText: © 2025 Clifford Weinmann <https://www.cliffordweinmann.com/>
#
# SPDX-License-Identifier: MIT-0

# Configuration for podman/docker images (molecule-platform:$platform.$VER)
CTPLATFORMS := centos-stream8 centos-stream9 debian12 debian13 fedora40 fedora41 fedora42 fedora43 sle15 sle16 ubuntu2204 ubuntu2404
CTREGISTRY := ghcr.io/clifford2
CTMOLECULEFILE := molecule/podman/molecule.yml

# Configuration for KubeVirt containerDisk images (kubevirt-containerdisk:$platform.$VER)
VMPLATFORMS := centos-stream9 centos-stream10 debian12 debian13 opensuse-15.6 ubuntu2404
VMREGISTRY := ghcr.io/clifford2
VMMOLECULEFILE := molecule/kubevirt/molecule.yml

# Use podman or docker?
# ifeq ($(shell command -v podman 2> /dev/null),)
# 	CONTAINER_ENGINE := docker
# else
# 	CONTAINER_ENGINE := podman
# endif
#
# Forcing use of podman, as docker code is experimental multi-arch, and not working yet
CONTAINER_ENGINE := podman

BUILD_TIME := $(shell TZ=UTC date '+%Y-%m-%dT%H:%M:%SZ')
GIT_REVISION := $(shell git rev-parse @)

# Decide on container engine to use
ifeq ($(CONTAINER_ENGINE),podman)
	BUILDARCH := $(shell podman version --format '{{.Client.OsArch}}' | cut -d/ -f2)
	BUILD_NOLOAD := podman build --pull=newer --platform linux/amd64
	BUILD_CMD := $(BUILD_NOLOAD)
else
	BUILDARCH := $(shell docker version --format '{{.Client.Arch}}')
	BUILD_NOLOAD := docker buildx build --platform linux/amd64,linux/arm64
	BUILD_CMD := $(BUILD_NOLOAD) --load
endif

.PHONY: help
help:
	@echo 'No default target defined - please specify what you want. Key targets:'
	@echo ''
	@echo 'build-container: Build podman/docker container images'
	@echo 'build-vm:        Build KubeVirt containerDisk images'
	@echo 'build:           Build all images'
	@echo 'updatever:       Update versions in our sample molecule.yml files (before "git push")'
	@echo 'showver:         Show current versions (handy for molecule.yml files)'

.PHONY: build
build: build-container build-vm

.PHONY: .envinfo
.envinfo:
	@echo "We're using $(CONTAINER_ENGINE) on $(BUILDARCH)"

# Show current Container & KubeVirt image versions
.PHONY: showver
showver: showver-container showver-vm

# Update container image versions in molecule/*/molecule.yml
.PHONY: updatever
updatever: updatever-container updatever-vm

# Get current podman/docker container image versions
.PHONY: showver-container
showver-container:
	@echo ''
	@echo 'Container image versions:'
	@echo ''
	@for platform in $(CTPLATFORMS); do \
		VER=v$$(awk 'BEGIN {FS="="} /ARG VERSION/ {print $$2}' podman/Containerfile.$$platform) ; \
		echo "molecule-platform:$$platform.$$VER" ; \
	done

# Build podman/docker container images (molecule-platform:$platform.$VER - no registry in name)
.PHONY: build-container
build-container:
	@for platform in $(CTPLATFORMS); do \
		VER=v$$(awk 'BEGIN {FS="="} /ARG VERSION/ {print $$2}' podman/Containerfile.$$platform) ; \
		$(BUILD_CMD) --build-arg=BUILD_TIME="$(BUILD_TIME)" --build-arg=GIT_REVISION="$(GIT_REVISION)" -f podman/Containerfile.$$platform -t molecule-platform:$$platform.$$VER . && \
		$(CONTAINER_ENGINE) tag molecule-platform:$$platform.$$VER molecule-platform:$$platform ; \
	done

# Tag podman/docker container images
.PHONY: tag-container
tag-container: updatever-container
	@for platform in $(CTPLATFORMS); do \
		VER=v$$(awk 'BEGIN {FS="="} /ARG VERSION/ {print $$2}' podman/Containerfile.$$platform) ; \
		$(CONTAINER_ENGINE) tag molecule-platform:$$platform.$$VER $(CTREGISTRY)/molecule-platform:$$platform.$$VER ; \
		$(CONTAINER_ENGINE) tag molecule-platform:$$platform.$$VER $(CTREGISTRY)/molecule-platform:$$platform ; \
	done

# Update container image versions in molecule/podman/molecule.yml
.PHONY: updatever-container
updatever-container:
	@for platform in $(CTPLATFORMS); do \
		VER=v$$(awk 'BEGIN {FS="="} /ARG VERSION/ {print $$2}' podman/Containerfile.$$platform) ; \
		echo "molecule-platform:$$platform.$$VER" ; \
		sed -i -e "s|image: .*/molecule-platform:$$platform..*|image: $(CTREGISTRY)/molecule-platform:$$platform.$$VER|" $(CTMOLECULEFILE) ; \
	done

# Push podman/docker container images (redundant, as images are built by GitHub Actions)
.PHONY: .push-container
.push-container: tag-container
	@for platform in $(CTPLATFORMS); do \
		VER=v$$(awk 'BEGIN {FS="="} /ARG VERSION/ {print $$2}' podman/Containerfile.$$platform) ; \
		$(CONTAINER_ENGINE) push $(CTREGISTRY)/molecule-platform:$$platform.$$VER ; \
		$(CONTAINER_ENGINE) push $(CTREGISTRY)/molecule-platform:$$platform ; \
	done

# Build & Push podman/docker container images
.PHONY: .build-push-container
.build-push-container: build-container .push-container

# Show current KubeVirt containerDisk image versions
.PHONY: showver-vm
showver-vm:
	@echo ''
	@echo 'KubeVirt containerDisk image versions:'
	@echo ''
	@for platform in $(VMPLATFORMS); do \
		VER=v$$(awk 'BEGIN {FS="="} /ARG VERSION/ {print $$2}' kubevirt/Containerfile.$$platform) ; \
		echo kubevirt-containerdisk:$$platform.$$VER ; \
	done

# Build KubeVirt containerDisk images (kubevirt-containerdisk:$platform.$VER - no registry in name)
.PHONY: build-vm
build-vm:
	@for platform in $(VMPLATFORMS); do \
		VER=v$$(awk 'BEGIN {FS="="} /ARG VERSION/ {print $$2}' kubevirt/Containerfile.$$platform) ; \
		$(BUILD_CMD) --build-arg=BUILD_TIME="$(BUILD_TIME)" --build-arg=GIT_REVISION="$(GIT_REVISION)" -f kubevirt/Containerfile.$$platform -t kubevirt-containerdisk:$$platform.$$VER . ; \
		$(CONTAINER_ENGINE) tag kubevirt-containerdisk:$$platform.$$VER kubevirt-containerdisk:$$platform ; \
	done

# Tag KubeVirt containerDisk images
.PHONY: tag-vm
tag-vm: updatever-vm
	@for platform in $(VMPLATFORMS); do \
		VER=v$$(awk 'BEGIN {FS="="} /ARG VERSION/ {print $$2}' kubevirt/Containerfile.$$platform) ; \
		echo $(VMREGISTRY)/kubevirt-containerdisk:$$platform.$$VER ; \
		$(CONTAINER_ENGINE) tag kubevirt-containerdisk:$$platform.$$VER $(VMREGISTRY)/kubevirt-containerdisk:$$platform.$$VER ; \
		$(CONTAINER_ENGINE) tag kubevirt-containerdisk:$$platform.$$VER $(VMREGISTRY)/kubevirt-containerdisk:$$platform ; \
	done

# Update container image versions in molecule/kubevirt/molecule.yml
.PHONY: updatever-vm
updatever-vm:
	@for platform in $(VMPLATFORMS); do \
		VER=v$$(awk 'BEGIN {FS="="} /ARG VERSION/ {print $$2}' kubevirt/Containerfile.$$platform) ; \
		echo kubevirt-containerdisk:$$platform.$$VER ; \
		sed -i -e "s|image: .*/kubevirt-containerdisk:$$platform..*|image: $(VMREGISTRY)/kubevirt-containerdisk:$$platform.$$VER|" $(VMMOLECULEFILE) ; \
	done

# Push KubeVirt containerDisk images (redundant, as images are built by GitHub Actions)
.PHONY: .push-vm
.push-vm: tag-vm
	@for platform in $(VMPLATFORMS); do \
		VER=v$$(awk 'BEGIN {FS="="} /ARG VERSION/ {print $$2}' kubevirt/Containerfile.$$platform) ; \
		echo $(VMREGISTRY)/kubevirt-containerdisk:$$platform.$$VER ; \
		$(CONTAINER_ENGINE) push $(VMREGISTRY)/kubevirt-containerdisk:$$platform.$$VER ; \
		$(CONTAINER_ENGINE) push $(VMREGISTRY)/kubevirt-containerdisk:$$platform ; \
	done

# Build & Push KubeVirt containerDisk images
.PHONY: .build-push-vm
.build-push-vm: build-vm .push-vm

.PHONY: yamllint
yamllint:
	find . -type f \( -name "*.yaml" -o -name "*.yml" \) -print | xargs yamllint

# # Copy container image from Docker to Podman (temporary target while testing docker cross-platform builds)
# .PHONY: .cp-container-docker-to-podman
# .cp-container-docker-to-podman:
# 	@for platform in $(CTPLATFORMS); do \
# 		VER=v$$(awk 'BEGIN {FS="="} /ARG VERSION/ {print $$2}' podman/Containerfile.$$platform) ; \
# 		docker save molecule-platform:$$platform.$$VER | podman load ; \
# 		podman tag molecule-platform:$$platform.$$VER molecule-platform:$$platform ; \
# 	done

# # Copy KubeVirt image from Docker to Podman (temporary target while testing docker cross-platform builds)
# .PHONY: .cp-vm-docker-to-podman
# .cp-vm-docker-to-podman:
# 	@for platform in $(VMPLATFORMS); do \
# 		VER=v$$(awk 'BEGIN {FS="="} /ARG VERSION/ {print $$2}' kubevirt/Containerfile.$$platform) ; \
# 		docker save kubevirt-containerdisk:$$platform.$$VER | podman load ; \
# 		podman tag kubevirt-containerdisk:$$platform.$$VER kubevirt-containerdisk:$$platform ; \
# 	done
