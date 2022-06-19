#!/bin/bash

PWD="$(echo $(pwd))"

diff -u "$PWD/a70_overlay/build/build.sh" "$PWD/patches/build.sh" > "$PWD/patches/build.patch"