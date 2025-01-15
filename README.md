# Systemd-enabled Container Images for Ansible Molecule

These Containerfiles build container images with systemd and Python,
for use by Ansible [`molecule`](https://ansible.readthedocs.io/projects/molecule/).

## Containerfiles

Our Containerfiles:

| Linux Distribution             | Containerfile                                                  | Image name                   |
| ------------------------------ | -------------------------------------------------------------- | ---------------------------- |
| CentOS Stream 8                | [`Containerfile.centos-stream8`](Containerfile.centos-stream8) | molecule-platform:centos8    |
| CentOS Stream 9                | [`Containerfile.centos-stream9`](Containerfile.centos-stream9) | molecule-platform:centos9    |
| Debian 12 (Bookworm)           | [`Containerfile.debian12`](Containerfile.debian12)             | molecule-platform:debian12   |
| Fedora 42                      | [`Containerfile.fedora42`](Containerfile.fedora42)             | molecule-platform:fedora42   |
| SLE BCI (SLES 15) based        | [`Containerfile.sle15`](Containerfile.sle15)                   | molecule-platform:sle15      |
| Ubuntu 22.04 (Jammy Jellyfish) | [`Containerfile.ubuntu2204`](Containerfile.ubuntu2204)         | molecule-platform:ubuntu2204 |
| Ubuntu 24.04 (Noble Numbat)    | [`Containerfile.ubuntu2404`](Containerfile.ubuntu2404)         | molecule-platform:ubuntu2404 |

Example Containerfiles:

- Our Debian & Ubuntu images are based on [`Containerfile.example-debian`](Containerfile.example-debian), from <https://github.com/alehaa/docker-debian-systemd>
- Our images for the Red Hat family are based on UBI 9 - [`Containerfile.example-ubi9-init`](Containerfile.example-ubi9-init), from [`registry.access.redhat.com/ubi9/ubi-init:9.5-1734512956`](https://catalog.redhat.com/software/containers/ubi9-init/6183297540a2d8e95c82e8bd?image=67629d3c4a112c1ff1bdbb70&container-tabs=dockerfile)

## Build Instructions

Container images built from these files are available at <https://hub.docker.com/r/cliffordw/molecule-platform>.

To build your own images from this source, you can build all images with:

```sh
make build
```

Or build individual images with these commands:

```sh
podman build -f Containerfile.centos-stream8 -t molecule-platform:centos8 .
podman build --pull -f Containerfile.centos-stream9 -t molecule-platform:centos9 .
podman build -f Containerfile.debian12 -t molecule-platform:debian12 .
podman build --pull -f Containerfile.fedora42 -t molecule-platform:fedora42 .
podman build -f Containerfile.sle15 -t molecule-platform:sle15 .
podman build -f Containerfile.ubuntu2204 -t molecule-platform:ubuntu2204 .
podman build -f Containerfile.ubuntu2404 -t molecule-platform:ubuntu2404 .
```

## Additional Images

Other images that already contain systemd:

- `registry.access.redhat.com/ubi9/ubi-init:9.5`
- `quay.io/centos/centos:stream10`

## Molecule Example

An example Molecule configuration can be found in [`molecule/default/`](molecule/default).

Run with:

```sh
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install molecule 'ansible-core<2.17'
molecule test
```
