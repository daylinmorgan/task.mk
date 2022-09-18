#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../functions.sh"

cmd 'make -f check/check.mk help'
cmd 'make -f check/check.mk check'
msg "# Let's try again but instead say no this time"
cmd 'make -f check/check.mk check'


