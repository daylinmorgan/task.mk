.PHONY: check
check: ## get user confirmation or exit
	$(call tconfirm,Would you like to proceed?)
	@echo "you said yes!"

define USAGE
{a.$(HEADER_STYLE)}usage:{a.end}\n  make <recipe>\n\n  interactivity w/ task.mk\n
endef

.DEFAULT_GOAL = help
include .task.mk
