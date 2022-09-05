# ---- CONFIG ---- #
HEADER_COLOR ?= b_cyan
PARAMS_COLOR ?= b_magenta
ACCENT_COLOR ?= b_yellow
GOAL_COLOR ?= $(ACCENT_COLOR)
MSG_COLOR ?= faint
HELP_SEP ?= |
EPILOG ?=

# python f-string literal
define USAGE ?=
{color.$(HEADER_COLOR)}usage{color.end}:
  make <recipe>

endef
