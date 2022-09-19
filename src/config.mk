# ---- [config] ---- #
HEADER_STYLE ?= b_cyan
ACCENT_STYLE ?= b_yellow
PARAMS_STYLE ?= $(ACCENT_STYLE)
GOAL_STYLE ?= $(ACCENT_STYLE)
MSG_STYLE ?= faint
DIVIDER_STYLE ?= default
DIVIDER ?= ─
HELP_SEP ?= │
# python f-string literals
EPILOG ?=
USAGE ?={ansi.$(HEADER_STYLE)}usage{ansi.end}:\n  make <recipe>\n
