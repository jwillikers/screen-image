#!/usr/bin/env fish

set -l options (fish_opt --short a --long architecture --required-val)
set -a options (fish_opt --short h --long help)

argparse --max-args 0 $options -- $argv
or exit

if set -q _flag_help
    echo "build [-a|--architecture] [-h|--help]"
    exit 0
end

set -l architecture (podman info --format={{".Host.Arch"}})
if set -q _flag_architecture
    set architecture $_flag_architecture
end
echo "The image will be tested for the $architecture architecture."

podman run --rm --arch $architecture --name test-container -it localhost/screen -v
or exit
