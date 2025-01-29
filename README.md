# Container Images for Ansible Molecule

## About

This repository is used for building container images for various Linux distributions, for use by Ansible [`molecule`](https://ansible.readthedocs.io/projects/molecule/).

Two varieties are available.

The first set of files build images for use with podman/docker platforms.

The second set of files build KubeVirt containerDisk images.

## Podman / Docker Images

### Containerfiles

Our Containerfiles (in the [`podman/`](podman) directory):

| Linux Distribution             | Containerfile                                                         | Image name                   |
| ------------------------------ | --------------------------------------------------------------------- | ---------------------------- |
| CentOS Stream 8                | [`Containerfile.centos-stream8`](podman/Containerfile.centos-stream8) | molecule-platform:centos8    |
| CentOS Stream 9                | [`Containerfile.centos-stream9`](podman/Containerfile.centos-stream9) | molecule-platform:centos9    |
| Debian 12 (Bookworm)           | [`Containerfile.debian12`](podman/Containerfile.debian12)             | molecule-platform:debian12   |
| Fedora 40                      | [`Containerfile.fedora40`](podman/Containerfile.fedora40)             | molecule-platform:fedora40   |
| Fedora 41                      | [`Containerfile.fedora41`](podman/Containerfile.fedora41)             | molecule-platform:fedora41   |
| Fedora 42                      | [`Containerfile.fedora42`](podman/Containerfile.fedora42)             | molecule-platform:fedora42   |
| SLE BCI (SLES 15) based        | [`Containerfile.sle15`](podman/Containerfile.sle15)                   | molecule-platform:sle15      |
| Ubuntu 22.04 (Jammy Jellyfish) | [`Containerfile.ubuntu2204`](podman/Containerfile.ubuntu2204)         | molecule-platform:ubuntu2204 |
| Ubuntu 24.04 (Noble Numbat)    | [`Containerfile.ubuntu2404`](podman/Containerfile.ubuntu2404)         | molecule-platform:ubuntu2404 |

Example Containerfiles:

- Our Debian & Ubuntu images are based on [`Containerfile.example-debian`](podman/Containerfile.example-debian), from <https://github.com/alehaa/docker-debian-systemd>
- Our images for the Red Hat family are based on UBI 9 - [`Containerfile.example-ubi9-init`](podman/Containerfile.example-ubi9-init), from [`registry.access.redhat.com/ubi9/ubi-init:9.5-1734512956`](https://catalog.redhat.com/software/containers/ubi9-init/6183297540a2d8e95c82e8bd?image=67629d3c4a112c1ff1bdbb70&container-tabs=dockerfile)

### Build Instructions

Container images built from these files are available at <https://hub.docker.com/r/cliffordw/molecule-platform>.

To build your own images from this source, you can build all images with:

```sh
make build-container
```

Or build individual images with these commands:

```sh
podman build -f podman/Containerfile.centos-stream8 -t molecule-platform:centos8 .
podman build --pull -f podman/Containerfile.centos-stream9 -t molecule-platform:centos9 .
podman build -f podman/Containerfile.debian12 -t molecule-platform:debian12 .
podman build --pull -f podman/Containerfile.fedora40 -t molecule-platform:fedora40 .
podman build --pull -f podman/Containerfile.fedora41 -t molecule-platform:fedora41 .
podman build --pull -f podman/Containerfile.fedora42 -t molecule-platform:fedora42 .
podman build -f podman/Containerfile.sle15 -t molecule-platform:sle15 .
podman build -f podman/Containerfile.ubuntu2204 -t molecule-platform:ubuntu2204 .
podman build -f podman/Containerfile.ubuntu2404 -t molecule-platform:ubuntu2404 .
```

### Additional Images

Other images that already contain systemd:

- `registry.access.redhat.com/ubi9/ubi-init:9.5`
- [`quay.io/centos/centos:stream10`](https://quay.io/repository/centos/centos?tab=tags&tag=stream10)

### Molecule Example

An example Molecule configuration can be found in [`molecule/podman/`](molecule/podman).

Run with:

```sh
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install molecule 'ansible-core<2.17'
molecule test -s podman
```

## KubeVirt containerDisk Images

An example Molecule configuration can be found in [`molecule/podman/`](molecule/podman).

### Containerfiles

Our Containerfiles (in the [`kubevirt/`](kubevirt) directory):

### Build Instructions

Container images built from these files are available at <https://hub.docker.com/r/cliffordw/kubevirt-containerdisk>.

To build your own images from this source, you can build all images with:

```sh
make build-vm
```

### Additional Images

Other available images (requires authentication to pull):

- `registry.redhat.io/rhel9/rhel-guest-image`
- `registry.redhat.io/rhel8/rhel-guest-image`

### Molecule Example

An example Molecule configuration can be found in [`molecule/kubevirt/`](molecule/kubevirt).

Run with:

```sh
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install molecule 'ansible-core<2.17'
python3 -m pip install -r molecule/shared/kubevirt-requirements.txt
molecule test -s kubevirt
```

## License & Disclaimer

The original Dockerfile is © 2018-2019 Alexander Haase <ahaase@alexhaase.de>.

Modifications, and all other files are © Clifford Weinmann <https://www.cliffordweinmann.com/>.

This code is provided *AS IS*, without warranty of any kind.
See [`LICENSES/`](LICENSES) for the full license text and disclaimers.

## Security

This code is updated as often as possible, but support is provided on a best effort basis only.

Please report any problems or vulnerabilities by opening a [GitHub issue here](https://github.com/clifford2/molecule-containers/issues).
