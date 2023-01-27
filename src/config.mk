# ---- [config] ---- #
HEADER_STYLE ?= b_cyan
ACCENT_STYLE ?= b_yellow
PARAMS_STYLE ?= $(ACCENT_STYLE)
GOAL_STYLE ?= $(ACCENT_STYLE)
MSG_STYLE ?= faint
DIVIDER ?= ─
DIVIDER_STYLE ?= default
HELP_SEP ?= │
WRAP ?= 100
# python f-string literals
EPILOG ?=
USAGE ?={ansi.header}usage{ansi.end}:\n  make <recipe>\n
PHONIFY ?=
