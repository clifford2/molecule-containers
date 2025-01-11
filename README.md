# Systemd-enabled Container Images for Ansible Molecule

These Dockerfiles build container images that contain systemd and Python,
for use by Ansible [`molecule`](https://ansible.readthedocs.io/projects/molecule/).

## Dockerfiles

Our Dockerfiles:

- [`Dockerfile.centos-stream8`](Dockerfile.centos-stream8): CentOS Stream 8
- [`Dockerfile.centos-stream9`](Dockerfile.centos-stream9): CentOS Stream 9
- [`Dockerfile.debian12`](Dockerfile.debian12): Debian 12 (Bookworm)
- [`Dockerfile.fedora42`](Dockerfile.fedora42): Fedora 42
- [`Dockerfile.ubuntu2404`](Dockerfile.ubuntu2404): Ubuntu 24.04 (Noble Numbat)
- [`Dockerfile.ubuntu2204`](Dockerfile.ubuntu2204): Ubuntu 22.04 (Jammy Jellyfish)

Example Dockerfiles:

- Our Debian & Ubuntu images is based on `Dockerfile.example-debian`, from <https://github.com/alehaa/docker-debian-systemd>
- Our images for the Red Hat family are based on UBI 9 - `Dockerfile.example-ubi9-init`, from `registry.access.redhat.com/ubi9/ubi-init:9.5-1734512956`

## Build Instructions

```sh
podman build -f Dockerfile.debian12 -t molecule-platform:debian12 .
podman build -f Dockerfile.ubuntu2404 -t molecule-platform:ubuntu2404 .
podman build -f Dockerfile.ubuntu2204 -t molecule-platform:ubuntu2204 .
podman build -f Dockerfile.centos-stream8 -t molecule-platform:centos8 .
podman build --pull -f Dockerfile.centos-stream9 -t molecule-platform:centos9 .
podman build --pull -f Dockerfile.fedora42 -t molecule-platform:fedora42 .
```

## Additional Images

Other images that already contain systemd:

- `registry.access.redhat.com/ubi9/ubi-init:9.5`
- `quay.io/centos/centos:stream10`

## Molecule Example

An example Molecule configuration can be found in [`molecule/default/`](molecule/default).
