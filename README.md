# Container Images for Ansible Molecule

## About

[Molecule](https://docs.ansible.com/projects/molecule/) is a testing framework
for the [Ansible](https://github.com/ansible/ansible) IT automation system,
designed for developing and testing Ansible collections, playbooks, and roles.

This code builds container images for various Linux distributions, for use
as Ansible `molecule` testing platforms.

Images for two testing scenarios are available, namely:

- Container images, for testing your playbooks in [Podman](https://podman.io/) or [Docker](https://www.docker.com/) containers
- containerDisk images, for testing your playbooks in [KubeVirt](https://kubevirt.io/) VMs

## Container Images

For many Ansible playbooks that target Linux systems, one of the easiest ways to
test them against different Linux distributions & versions, is in containers.

One limitation of most Linux base container images is that they are created
primarily for running a single application, and therefore do not have any
`init` process. In contrast, many playbooks are written for VMs, and assume
the presense of systemd.  The images in this repository addresses that, by
simply adding systemd to the base images.

### Platforms With Existing Images

The following images already contain systemd, and can be used as is:

- Red Hat Universal Base Image 8: `registry.access.redhat.com/ubi8/ubi-init:8.10`
- Red Hat Universal Base Image 9: `registry.access.redhat.com/ubi9/ubi-init:9.8`
- Red Hat Universal Base Image 10: `registry.access.redhat.com/ubi10/ubi-init:10.2`
- CentOS Stream 10: [`quay.io/centos/centos:stream10`](https://quay.io/repository/centos/centos?tab=tags&tag=stream10)

### Our Custom Images

Our Containerfiles (in the [`podman/`](podman) directory):

| Linux Distribution                       | Containerfile                                                         | Image name                       |
| ---------------------------------------- | --------------------------------------------------------------------- | -------------------------------- |
| CentOS Stream 8 (*EOL as of 2024-05-31*) | [`Containerfile.centos-stream8`](podman/Containerfile.centos-stream8) | molecule-platform:centos-stream8 |
| CentOS Stream 9                          | [`Containerfile.centos-stream9`](podman/Containerfile.centos-stream9) | molecule-platform:centos-stream9 |
| Debian 12 (Bookworm)                     | [`Containerfile.debian12`](podman/Containerfile.debian12)             | molecule-platform:debian12       |
| Debian 13 (Trixie)                       | [`Containerfile.debian13`](podman/Containerfile.debian13)             | molecule-platform:debian13       |
| Fedora 40 (*EOL*)                        | [`Containerfile.fedora40`](podman/Containerfile.fedora40)             | molecule-platform:fedora40       |
| Fedora 41 (*EOL 2025-12-15*)             | [`Containerfile.fedora41`](podman/Containerfile.fedora41)             | molecule-platform:fedora41       |
| Fedora 42                                | [`Containerfile.fedora42`](podman/Containerfile.fedora42)             | molecule-platform:fedora42       |
| Fedora 43                                | [`Containerfile.fedora43`](podman/Containerfile.fedora43)             | molecule-platform:fedora43       |
| Fedora 44                                | [`Containerfile.fedora44`](podman/Containerfile.fedora44)             | molecule-platform:fedora44       |
| SLE BCI (SLES 15) based                  | [`Containerfile.sle15`](podman/Containerfile.sle15)                   | molecule-platform:sle15          |
| SLE BCI (SLES 16) based                  | [`Containerfile.sle16`](podman/Containerfile.sle16)                   | molecule-platform:sle16          |
| Ubuntu 22.04 (Jammy Jellyfish)           | [`Containerfile.ubuntu2204`](podman/Containerfile.ubuntu2204)         | molecule-platform:ubuntu2204     |
| Ubuntu 24.04 (Noble Numbat)              | [`Containerfile.ubuntu2404`](podman/Containerfile.ubuntu2404)         | molecule-platform:ubuntu2404     |
| Ubuntu 26.04 (Resolute Raccoon)          | [`Containerfile.ubuntu2604`](podman/Containerfile.ubuntu2604)         | molecule-platform:ubuntu2604     |

### Build Instructions

Container images for `amd64` & `arm64`, built from these files, are available at
[ghcr.io/clifford2/molecule-platform](https://github.com/clifford2/molecule-containers/pkgs/container/molecule-platform),
as `ghcr.io/clifford2/<image-name-from-list-above>` (for example `ghcr.io/clifford2/molecule-platform:centos-stream9`).

To build your own images from this source, you can build all images with:

```sh
make build-container
```

Or build individual images with these commands:

```sh
make CTPLATFORMS=centos-stream8 build-container
make CTPLATFORMS=centos-stream9 build-container
make CTPLATFORMS=debian12 build-container
make CTPLATFORMS=debian13 build-container
make CTPLATFORMS=fedora40 build-container
make CTPLATFORMS=fedora41 build-container
make CTPLATFORMS=fedora42 build-container
make CTPLATFORMS=fedora43 build-container
make CTPLATFORMS=fedora44 build-container
make CTPLATFORMS=sle15 build-container
make CTPLATFORMS=sle16 build-container
make CTPLATFORMS=ubuntu2204 build-container
make CTPLATFORMS=ubuntu2404 build-container
make CTPLATFORMS=ubuntu2604 build-container
```

### Molecule Example

#### Podman

These images were developed and tested primarily for using
[Podman](https://podman.io/) containers as test hosts.

An example Molecule scenario can be found in
[`molecule/podman/`](molecule/podman).

Run the Molecule scenario with these commands:

```sh
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install molecule 'ansible-core>=2.16,<2.17'
python3 -m pip install -r molecule/docker/requirements.txt
ansible-galaxy install -r molecule/podman/collections.yml
molecule test -s podman
```

Please note the use of **Ansible 2.16** here. This is because our test hosts include RHEL 8 based containers, and
[Newer versions of Ansible don't work with RHEL 8](https://www.jeffgeerling.com/blog/2024/newer-versions-ansible-dont-work-rhel-8/),
particularly for DNF package tasks.
It is worth noting that Ansible Core 2.16 is also the default version in Ansible Automation Platform 2.5, 2.6 & 2.7 (2026-06).

More recent Ansible versions work for all other images though.
Our most recent tests were performed on 2026-06-24, using python 3.12, ansible-core 2.20.6 and molecule 25.12.0.

#### Docker

An example Molecule scenario also exists for [Docker](https://www.docker.com/) containers, in [`molecule/docker`](molecule/docker).
This currently works for Red Hat and SUSE based images, but not for Debian based images (where there are unresolved cgroup related problems).

Run the Molecule scenario with these commands:

```sh
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install molecule 'ansible-core>=2.16,<2.17'
python3 -m pip install -r molecule/docker/requirements.txt
ansible-galaxy install -r molecule/docker/collections.yml
molecule test -s docker
```

## KubeVirt containerDisk Images

For some Ansible playbooks, the limitations of contains make them less than ideal for testing.

For such playbooks, we can test in a VM, and one way to do that is inside Kubernetes, with [KubeVirt](https://kubevirt.io/).

KubeVirt uses [`containerDisk`](https://kubevirt.io/user-guide/storage/disks_and_volumes/#containerdisk)
images, which store and distribute VM disks in the container image registry.

### Platforms With Existing Images

As of 2026-06, Containerdisks are readily available elsewhere, and are *usually more up to date* than the ones in this repository.
Available images include:

- [KubeVirt curated Containerdisks](https://github.com/kubevirt/containerdisks). As of 2026-01, available images include:
	- [CentOS Stream](https://quay.io/repository/containerdisks/centos-stream) 9 & 10
	- [Fedora](https://quay.io/repository/containerdisks/fedora) 39 - 44
	- [Ubuntu](https://quay.io/repository/containerdisks/ubuntu) 22.04, 24.04, 25.04
	- [OpenSUSE Tumbleweed](https://quay.io/repository/containerdisks/opensuse-tumbleweed)
	- [OpenSUSE Leap](https://quay.io/repository/containerdisks/opensuse-leap) 15.6 & 16.0
	- [Debian](https://quay.io/repository/containerdisks/debian) 11 - 13
- RHEL 9: `registry.redhat.io/rhel9/rhel-guest-image` (*requires authentication to pull*)
- RHEL 10: `registry.redhat.io/rhel8/rhel-guest-image` (*requires authentication to pull*)

### Our Containerfiles

Our Containerfiles (in the [`kubevirt/`](kubevirt) directory):

| Linux Distribution              | Containerfile                                                             | Image name                             |
| ------------------------------- | ------------------------------------------------------------------------- | -------------------------------------- |
| CentOS Stream 9                 | [`Containerfile.centos-stream9`](kubevirt/Containerfile.centos-stream9)   | kubevirt-containerdisk:centos-stream9  |
| CentOS Stream 10                | [`Containerfile.centos-stream10`](kubevirt/Containerfile.centos-stream10) | kubevirt-containerdisk:centos-stream10 |
| Debian 12 (Bookworm)            | [`Containerfile.debian12`](kubevirt/Containerfile.debian12)               | kubevirt-containerdisk:debian12        |
| Debian 13 (Trixie)              | [`Containerfile.debian13`](kubevirt/Containerfile.debian13)               | kubevirt-containerdisk:debian13        |
| openSUSE Leap 15.6              | [`Containerfile.opensuse-15.6`](kubevirt/Containerfile.opensuse-15.6)     | kubevirt-containerdisk:opensuse-15.6   |
| Ubuntu 24.04 (Noble Numbat)     | [`Containerfile.ubuntu2404`](kubevirt/Containerfile.ubuntu2404)           | kubevirt-containerdisk:ubuntu2404      |
| Ubuntu 26.04 (Resolute Raccoon) | [`Containerfile.ubuntu2604`](kubevirt/Containerfile.ubuntu2604)           | kubevirt-containerdisk:ubuntu2604      |

### Build Instructions

Container images for `amd64`, built from these files, are available at
[ghcr.io/clifford2/kubevirt-containerdisk](https://github.com/clifford2/molecule-containers/pkgs/container/kubevirt-containerdisk),
as `ghcr.io/clifford2/<image-name-from-list-above>` (for example `ghcr.io/clifford2/kubevirt-containerdisk:centos-stream10`).

To build your own images from this source, you can build all images with:

```sh
make build-vm
```

### Molecule Example

An example Molecule configuration can be found in [`molecule/kubevirt/`](molecule/kubevirt).

To use this example, deploy KubeVirt (try their [Quickstarts](https://kubevirt.io/user-guide/quickstarts/)),
then run Molecule with:

```sh
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install molecule ansible-core
python3 -m pip install -r molecule/kubevirt/requirements.txt
ansible-galaxy install -r molecule/kubevirt/collections.yml
molecule test -s kubevirt
```

## License & Disclaimer

Our Debian & Ubuntu Containerfiles are based on
[github.com/alehaa/docker-debian-systemd](https://github.com/alehaa/docker-debian-systemd/blob/master/Dockerfile),
which is © 2018-2019 Alexander Haase <ahaase@alexhaase.de>.

Modifications based on that file, and all other files, are © 2025 Clifford Weinmann <https://www.cliffordweinmann.com/>.

This code is provided *AS IS*, without warranty of any kind.
See [`LICENSES/`](LICENSES) for the full license text and disclaimers.

## Security

This code is updated as often as possible, but support is provided on a best effort basis only.

Please report any problems or vulnerabilities by opening a [GitHub issue here](https://github.com/clifford2/molecule-containers/issues).

## Other Use Cases

### Apple macOS Container Machine

Quoting from [github.com/apple/container](https://github.com/apple/container/blob/main/docs/container-machine.md):

> Container machine provides a highly integrated Linux environment that works seamlessly on your Mac. Container machines are fast, lightweight and persistent. They are based on standard OCI images that can be built and shared. Host integrations such as automatic user and home directory sharing provide quick and easy access to your Linux environment no matter where you are in a terminal.
>
> Any Linux image that includes `/sbin/init` works as a container machine.

The container images in this repo might therefore be handy for that purpose too :-)
