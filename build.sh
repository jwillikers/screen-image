#!/usr/bin/env bash
set -o errexit

############################################################
# Help                                                     #
############################################################
Help() {
	# Display Help
	echo "Generate a container image for running GNU Screen."
	echo
	echo "Syntax: build.sh [-a|h]"
	echo "options:"
	echo "a     Build for the specified target architecture, i.e. amd64, arm, arm64"
	echo "h     Print this Help."
	echo
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################

# Set variables
ARCHITECTURE="$(buildah info --format=\{\{".host.arch"\}\})"

############################################################
# Process the input options. Add options as needed.        #
############################################################
while getopts ":a:h" option; do
	case $option in
	h) # display Help
		Help
		exit
		;;
	a) # Enter a target architecture
		ARCHITECTURE=$OPTARG ;;
	\?) # Invalid option
		echo "Error: Invalid option"
		exit
		;;
	esac
done

CONTAINER=$(buildah from --arch "$ARCHITECTURE" scratch)
IMAGE="screen"
MOUNTPOINT=$(buildah mount "$CONTAINER")

podman run --arch "$ARCHITECTURE" -v "$MOUNTPOINT":/mnt:Z registry.fedoraproject.org/fedora:latest bash -c "dnf -y install --installroot /mnt --releasever 34 glibc-minimal-langpack screen --nodocs --setopt install_weak_deps=False"

podman run --arch "$ARCHITECTURE" -v "$MOUNTPOINT":/mnt:Z registry.fedoraproject.org/fedora:latest bash -c "dnf clean all -y --installroot /mnt --releasever 34"

buildah unmount "$CONTAINER"

buildah config --cmd "screen" "$CONTAINER"

buildah config --label "io.containers.autoupdate=registry" "$CONTAINER"

buildah config --author "jordan@jwillikers.com" "$CONTAINER"

buildah commit --squash "$CONTAINER" "$IMAGE"

buildah rm "$CONTAINER"
