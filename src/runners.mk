# ---- [python/bash script runner] ---- #

# modified from https://unix.stackexchange.com/a/223093
define \n


endef

escape_shellstring = $(subst `,\`,$(subst ",\",$(subst $$,\$$,$(subst \,\\,$1))))

escape_printf = $(subst \,\\,$(subst %,%%,$1))

create_string = $(subst $(\n),\n,$(call escape_shellstring,$(call escape_printf,$1)))


ifdef DEBUG
define py
@printf "Python Script:\n"
@printf -- "----------------\n"
@printf "$(call create_string,$($(1)))\n"
@printf -- "----------------\n"
@printf "$(call create_string,$($(1)))" | python3
endef
define tbash
@printf "Bash Script:\n"
@printf -- "----------------\n"
@printf "$(call create_string,$($(1)))\n"
@printf -- "----------------\n"
@printf "$(call create_string,$($(1)))" | bash
endef
else
py = @printf "$(call create_string,$($(1)))" | python3
tbash = @printf "$(call create_string,$($(1)))" | bash
endif

pysh = printf "$(call create_string,$($(1)))" | python3