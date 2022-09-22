# ---- [builtin recipes] ---- #
ifeq (help,$(firstword $(MAKECMDGOALS)))
  HELP_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
	export HELP_ARGS
endif
## h, help | show this help
ifdef HELP_ARGS
help: help-args
	$(error exiting early)
.PHONY: help-args
help-args:
	$(call py,help_py)
else
.PHONY: help h
h help:
	$(call py,help_py)
endif
.PHONY: _help
_help: export SHOW_HIDDEN=true
_help: help
ifdef PRINT_VARS
$(foreach v,$(PRINT_VARS),$(eval export $(v)))
.PHONY: vars v
vars v:
	$(call py,vars_py,$(PRINT_VARS))
endif
### | args: -ws --hidden
### task.mk builtins: | args: -d --hidden
## _print-ansi | show all possible ansi color code combinations
.PHONY:
_print-ansi:
	$(call py,print_ansi_py)
# functions to take f-string literals and pass to python print
tprint = $(call py,info_py,$(1))
tprint-sh = $(call pysh,info_py,$(1))
tconfirm = $(call py,confirm_py,$(1))
## _update-task.mk | downloads latest development version of task.mk
_update-task.mk:
	$(call tprint,{a.b_cyan}Updating task.mk{a.end})
	curl https://raw.githubusercontent.com/daylinmorgan/task.mk/main/task.mk -o .task.mk
export MAKEFILE_LIST
ifndef INHERIT_SHELL
SHELL := $(shell which bash)
endif
