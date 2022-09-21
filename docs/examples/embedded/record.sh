#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../functions.sh"

cmd 'make -f embedded/embedded.mk help'
cmd 'make -f embedded/embedded.mk list-embedded'
cmd 'make -f embedded/embedded.mk embedded-bash'

