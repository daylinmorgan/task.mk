## deps-only | a task/target with dependencies
.PHONY: deps-only
deps-only: foo

## foo | a dummy rule that depends on the local files
.PHONY: foo
foo: $(wildcard *)
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
include $(shell git rev-parse --show-toplevel)/task.mk

