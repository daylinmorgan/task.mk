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
{colors.$(HEADER_COLOR)}usage{colors.end}:
  make <recipe>

endef
