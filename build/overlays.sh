#!/bin/bash

PWD="$(echo $(pwd))"

# Build Google spoof overlays
for bin in "raven" "redfin" "sunfish" "coral" "cheetah" "bonito" "bluejay"
do
    bash $PWD/build/generate.sh google $bin $3 $4
done

# Build Samsung spoof overlays
for bin in "a70"
do
    bash $PWD/build/generate.sh samsung $bin $3 $4
done
