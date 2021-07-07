#!/usr/bin/env fish

set -l options (fish_opt --short h --long help)

argparse --max-args 0 $options -- $argv
or exit

if set -q _flag_help
    echo "build [-h|--help]"
    exit 0
end

podman run --rm --name test-container -it localhost/screen:latest -v
or exit
