# ---- [python/bash script runner] ---- #
###-- modified from https://unix.stackexchange.com/a/223093 -###
###- 
# possible posix process substitions solution:
# https://unix.stackexchange.com/a/639752 
# -### 
TASKMK_SHELL ?= $(shell cat /etc/shells | grep -E '/(bash|zsh)' | head -n 1)
ifndef TASKMK_SHELL
$(warning WARNING! task.mk features require bash or zsh)
endif
define _newline


endef
_escape_shellstring = $(subst ','\'',$(subst `,\`,$(subst ",\",$(subst $$,\$$,$(subst \,\\,$1)))))
_escape_printf = $(subst \,\\,$(subst %,%%,$1))
_create_string = $(subst $(_newline),\n,$(call _escape_shellstring,$(call _escape_printf,$1)))
_printline = printf -- "<----------------------------------->\n"
ifdef TASKMK_DEBUG
define _debug_runner
@printf "$(1) Script:\n";$(_printline);
@printf "$(call _create_string,$(3))\n" | cat -n
@$(_printline)
@$(2) <(printf "$(call _create_string,$(3))")
endef
py = $(call _debug_runner,Python,python3,$($(1)))
tbash = $(call _debug_runner,Bash,bash,$($(1)))
else
py = @$(TASKMK_SHELL) -c 'python3 <(printf "$(call _create_string,$($(1)))")'
tbash = @$(TASKMK_SHELL) -c '$(TASKMK_SHELL) <(printf "$(call _create_string,$($(1)))")'
endif
py-verbose = $(TASKMK_SHELL) -c 'python3 <(printf "$(call _create_string,$($(1)))")'
