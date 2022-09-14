# ---- [buitlin recipes] ---- #

## h, help | show this help
.PHONY: help h
help h:
	$(call py,help_py)

.PHONY: _help
_help: export SHOW_HIDDEN=true
_help: help

ifdef PRINT_VARS

$(foreach v,$(PRINT_VARS),$(eval export $(v)))

.PHONY: vars v
vars v:
	$(call py,vars_py,$(PRINT_VARS))

endif

## _print-ansi | show all possible ansi color code combinations
.PHONY:
_print-ansi:
	$(call py,print_ansi_py)

# functions to take f-string literals and pass to python print
tprint = $(call py,info_py,$(1))
tprint-sh = $(call pysh,info_py,$(1))

tconfirm = $(call py,confirm_py,$(1))

_update-task.mk:
	$(call tprint,Updating task.mk)
	curl https://raw.githubusercontent.com/daylinmorgan/task.mk/main/task.mk -o .task.mk

export MAKEFILE_LIST
