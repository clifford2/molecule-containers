# Container Images for Ansible Molecule

## About

This code builds container images for various Linux distributions, for use as Ansible [`molecule`](https://ansible.readthedocs.io/projects/molecule/) testing platforms.

Two varieties are available, namely:

- Container images, for testing your playbooks in [Podman](https://podman.io/) containers
- containerDisk images, for testing your playbooks in [KubeVirt](https://kubevirt.io/) VMs

## Container Images

These container images were developed and tested with [Podman](https://podman.io/).
Example code is available in the [`podman`](molecule/podman) Molecule scenario.

Although a Molecule scenario also exists for [Docker](https://www.docker.com/)
containers (see [`docker`](molecule/docker)), this doesn't cover all images
(notably Debian based images), and has not been tested thoroughly.

### Containerfiles

Our Containerfiles (in the [`podman/`](podman) directory):

| Linux Distribution             | Containerfile                                                         | Image name                   |
| ------------------------------ | --------------------------------------------------------------------- | ---------------------------- |
| CentOS Stream 8                | [`Containerfile.centos-stream8`](podman/Containerfile.centos-stream8) | molecule-platform:centos8    |
| CentOS Stream 9                | [`Containerfile.centos-stream9`](podman/Containerfile.centos-stream9) | molecule-platform:centos9    |
| Debian 12 (Bookworm)           | [`Containerfile.debian12`](podman/Containerfile.debian12)             | molecule-platform:debian12   |
| Debian 13 (Trixie)             | [`Containerfile.debian13`](podman/Containerfile.debian13)             | molecule-platform:debian13   |
| Fedora 40                      | [`Containerfile.fedora40`](podman/Containerfile.fedora40)             | molecule-platform:fedora40   |
| Fedora 41                      | [`Containerfile.fedora41`](podman/Containerfile.fedora41)             | molecule-platform:fedora41   |
| Fedora 42                      | [`Containerfile.fedora42`](podman/Containerfile.fedora42)             | molecule-platform:fedora42   |
| Fedora 43                      | [`Containerfile.fedora43`](podman/Containerfile.fedora43)             | molecule-platform:fedora43   |
| SLE BCI (SLES 15) based        | [`Containerfile.sle15`](podman/Containerfile.sle15)                   | molecule-platform:sle15      |
| SLE BCI (SLES 16) based        | [`Containerfile.sle16`](podman/Containerfile.sle16)                   | molecule-platform:sle16      |
| Ubuntu 22.04 (Jammy Jellyfish) | [`Containerfile.ubuntu2204`](podman/Containerfile.ubuntu2204)         | molecule-platform:ubuntu2204 |
| Ubuntu 24.04 (Noble Numbat)    | [`Containerfile.ubuntu2404`](podman/Containerfile.ubuntu2404)         | molecule-platform:ubuntu2404 |

*Our Debian & Ubuntu images are based on [`Containerfile.example-debian`](podman/Containerfile.example-debian),
from [github.com/alehaa/docker-debian-systemd](https://github.com/alehaa/docker-debian-systemd).*

### Build Instructions

Container images built from these files are available at [ghcr.io/clifford2/molecule-platform](https://github.com/clifford2/molecule-containers/pkgs/container/molecule-platform).

To build your own images from this source, you can build all images with:

```sh
make build-container
```

Or build individual images with these commands:

```sh
make CTPLATFORMS=centos8 build-container
make CTPLATFORMS=centos9 build-container
make CTPLATFORMS=debian12 build-container
make CTPLATFORMS=debian13 build-container
make CTPLATFORMS=fedora40 build-container
make CTPLATFORMS=fedora41 build-container
make CTPLATFORMS=fedora42 build-container
make CTPLATFORMS=fedora43 build-container
make CTPLATFORMS=sle15 build-container
make CTPLATFORMS=sle16 build-container
make CTPLATFORMS=ubuntu2204 build-container
make CTPLATFORMS=ubuntu2404 build-container
```

### Additional Images

The following images already contain systemd, and can be used as is in molecule scenarios:

- RHEL 9 UBI: `registry.access.redhat.com/ubi9/ubi-init:9.6`
- RHEL 10 UBI: `registry.access.redhat.com/ubi10/ubi-init:10.0`
- CentOS Stream 10 [`quay.io/centos/centos:stream10`](https://quay.io/repository/centos/centos?tab=tags&tag=stream10)

### Molecule Example

An example Molecule configuration can be found in [`molecule/podman/`](molecule/podman).

Run with:

```sh
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install molecule 'ansible-core<2.17'
ansible-galaxy install -r molecule/podman/collections.yml
molecule test -s podman
```

## KubeVirt containerDisk Images

These `containerDisk` images store and distribute VM disks in the container
image registry, and are used for creating KubeVirt VMs.

**Note 2026-01-03**: more up to date images are available at
<https://github.com/kubevirt/containerdisks>.

### Containerfiles

Our Containerfiles (in the [`kubevirt/`](kubevirt) directory):

| Linux Distribution           | Containerfile                                                             | Image name                        |
| ---------------------------- | ------------------------------------------------------------------------- | --------------------------------- |
| CentOS Stream 9              | [`Containerfile.centos-stream9`](kubevirt/Containerfile.centos-stream9)   | kubevirt-containerdisk:centos9    |
| CentOS Stream 10             | [`Containerfile.centos-stream10`](kubevirt/Containerfile.centos-stream10) | kubevirt-containerdisk:centos9    |
| Debian 12 (Bookworm)         | [`Containerfile.debian12`](kubevirt/Containerfile.debian12)               | kubevirt-containerdisk:debian12   |
| Debian 13 (Trixie)           | [`Containerfile.debian13`](kubevirt/Containerfile.debian13)               | kubevirt-containerdisk:debian13   |
| openSUSE 15.6                | [`Containerfile.opensuse-15.6`](kubevirt/Containerfile.opensuse-15.6)     | kubevirt-containerdisk:sle15      |
| Ubuntu 24.04 (Noble Numbat)  | [`Containerfile.ubuntu2404`](kubevirt/Containerfile.ubuntu2404)           | kubevirt-containerdisk:ubuntu2404 |

### Build Instructions

Container images built from these files are available at [ghcr.io/clifford2/kubevirt-containerdisk](https://github.com/clifford2/molecule-containers/pkgs/container/kubevirt-containerdisk).

To build your own images from this source, you can build all images with:

```sh
make build-vm
```

### Additional Images

Other available images:

- [KubeVirt curated Containerdisks](https://github.com/kubevirt/containerdisks)
- RHEL 9: `registry.redhat.io/rhel9/rhel-guest-image` (*requires authentication to pull*)
- RHEL 10: `registry.redhat.io/rhel8/rhel-guest-image` (*requires authentication to pull*)

### Molecule Example

An example Molecule configuration can be found in [`molecule/kubevirt/`](molecule/kubevirt).

Run with:

```sh
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install molecule 'ansible-core<2.17'
python3 -m pip install -r molecule/kubevirt/requirements.txt
ansible-galaxy install -r molecule/kubevirt/collections.yml
molecule test -s kubevirt
```

## License & Disclaimer

The original Debian systemd Dockerfile example, in which some of our images are based,
is © 2018-2019 Alexander Haase <ahaase@alexhaase.de>.

Modifications, and all other files are © 2025 Clifford Weinmann <https://www.cliffordweinmann.com/>.

This code is provided *AS IS*, without warranty of any kind.
See [`LICENSES/`](LICENSES) for the full license text and disclaimers.

## Security

This code is updated as often as possible, but support is provided on a best effort basis only.

Please report any problems or vulnerabilities by opening a [GitHub issue here](https://github.com/clifford2/molecule-containers/issues).
