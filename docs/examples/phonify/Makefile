a-task: ## will be marked phony
	@echo a-task executed

b-task: ## wont be marked phony |> --not-phony
	@echo b-task executed

c-task:
	@echo c-task executed

.PHONY: gen-task-files
gen-task-files:
	touch a-task b-task c-task
	
define USAGE
{a.$(HEADER_STYLE)}usage:{a.end}\n  make <recipe>\n
  phonifying tasks
  {a.faint}hint: there is also a c-task...{a.end}\n
endef

PHONIFY = true
.DEFAULT_GOAL = help
include .task.mk
