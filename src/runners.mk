# ---- [python/bash script runner] ---- #
###-- modified from https://unix.stackexchange.com/a/223093 -###
define \n


endef
escape_shellstring = $(subst `,\`,$(subst ",\",$(subst $$,\$$,$(subst \,\\,$1))))
escape_printf = $(subst \,\\,$(subst %,%%,$1))
create_string = $(subst $(\n),\n,$(call escape_shellstring,$(call escape_printf,$1)))
printline = printf -- "<----------------------------------->\n"
ifdef DEBUG
define _debug_runner
@printf "$(1) Script:\n";$(printline);printf "$(call create_string,$(3))\n";$(printline)
@printf "$(call create_string,$(3))" | $(2)
endef
py = $(call _debug_runner,Python,python3,$($(1)))
tbash = $(call _debug_runner,Bash,bash,$($(1)))
else
py = @python3 <(printf "$(call create_string,$($(1)))")
tbash = @bash <(printf "$(call create_string,$($(1)))")
endif
pysh = python3 <(printf "$(call create_string,$($(1)))")
