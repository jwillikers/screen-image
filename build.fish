#!/usr/bin/env fish

set -l options (fish_opt --short a --long architecture --required-val)
set -a options (fish_opt --short h --long help)

argparse --max-args 0 $options -- $argv
or exit

if set -q _flag_help
    echo "build [-a|--architecture] [-h|--help]"
    exit 0
end

set -l architecture (buildah info --format={{".host.arch"}})
if set -q _flag_architecture
    set architecture $_flag_architecture
end

set -l container (buildah from --arch $architecture scratch)
set -l image screen
set -l mountpoint (buildah mount $container)

podman run --arch $architecture --volume $mountpoint:/mnt:Z registry.fedoraproject.org/fedora:latest \
    bash -c "dnf -y install --installroot /mnt --releasever 34 glibc-minimal-langpack screen --nodocs --setopt install_weak_deps=False"
or exit

podman run --arch $architecture --volume $mountpoint:/mnt:Z registry.fedoraproject.org/fedora:latest \
    bash -c "dnf clean all -y --installroot /mnt --releasever 34"
or exit

buildah unmount $container
or exit

buildah config --cmd screen $container
or exit

buildah config --label io.containers.autoupdate=registry $container
or exit

buildah config --author jordan@jwillikers.com $container
or exit

buildah commit --rm --squash $container $image
or exit
