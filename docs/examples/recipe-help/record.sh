#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../functions.sh"

cmd 'make -f recipe-help/recipe-help.mk help'
cmd 'make -f recipe-help/recipe-help.mk help help'
cmd 'make -f recipe-help/recipe-help.mk help deps-only'
cmd 'make -f recipe-help/recipe-help.mk help foo'
cmd 'make -f recipe-help/recipe-help.mk help bar'

sleep 1
