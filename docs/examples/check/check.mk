msgfmt = {a.style('==>','bold')} {a.style('$(1)','b_magenta')} {a.style('<==','bold')}
msg = $(call tprint,$(call msgfmt ,$(1)))


## check | get user confirmation or exit
.PHONY: check
check:
	$(call tconfirm,Would you like to proceed?)
	@echo "you said yes!"

define USAGE
{a.$(HEADER_STYLE)}usage:{a.end}
	make <recipe>
	
	interactivity w/ task.mk\n
endef

.DEFUALT_GOAL = help
include $(shell git rev-parse --show-toplevel)/task.mk

