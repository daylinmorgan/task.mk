# ---- [builtin recipes] ---- #
ifeq (help,$(firstword $(MAKECMDGOALS)))
  HELP_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
	export HELP_ARGS
endif
h help: ## show this help
	$(call py,help_py)
_help: export SHOW_HIDDEN=true
_help: help
ifdef PRINT_VARS
$(foreach v,$(PRINT_VARS),$(eval export $(v)))
.PHONY: vars v
vars v:
	$(call py,vars_py,$(PRINT_VARS))
endif
### |> -ws --hidden
### task.mk builtins: |> -d --hidden
_print-ansi: ## show all possible ansi color code combinations
	$(call py,print_ansi_py)
# functions to take f-string literals and pass to python print
tprint = $(call py,print_py,$(1))
tprint-sh = $(call pysh,print_py,$(1))
tconfirm = $(call py,confirm_py,$(1))
_update-task.mk: ## downloads latest development version of task.mk
	$(call tprint,{a.b_cyan}Updating task.mk{a.end})
	curl https://raw.githubusercontent.com/daylinmorgan/task.mk/main/task.mk -o .task.mk
.PHONY: h help _help _print-ansi _update-task.mk
TASK_MAKEFILE_LIST := $(filter-out $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)),$(MAKEFILE_LIST))
export MAKEFILE_LIST MAKE TASK_MAKEFILE_LIST
ifndef INHERIT_SHELL
SHELL := $(shell which bash)
endif
