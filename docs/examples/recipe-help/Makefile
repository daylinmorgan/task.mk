.PHONY: deps-only
deps-only: foo ## a task/target with dependencies

.PHONY: foo
foo: $(wildcard *) ## a dummy rule that depends on the local files
	@echo 'this is a dummy rule'

# bar but no docstring
.PHONY: bar
bar:
	@echo 'some rule with no help string'

define USAGE
{a.header}usage:{a.end}
	make <recipe>
	make help <recipe>

endef

.DEFAULT_GOAL = help
include .task.mk

