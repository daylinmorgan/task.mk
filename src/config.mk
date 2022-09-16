# ---- [config] ---- #
HEADER_COLOR ?= b_cyan
PARAMS_COLOR ?= b_magenta
ACCENT_COLOR ?= b_yellow
GOAL_COLOR ?= $(ACCENT_COLOR)
MSG_COLOR ?= faint
DIVIDER_COLOR ?= default
DIVIDER ?= ─
HELP_SEP ?= │
# python f-string literals
EPILOG ?=
USAGE ?={ansi.$(HEADER_COLOR)}usage{ansi.end}:\n  make <recipe>
