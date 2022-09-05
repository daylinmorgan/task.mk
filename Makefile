VERSION ?= $(shell git describe --tags --always --dirty | sed s'/dirty/dev/')
TEMPLATES := $(shell find src/ -type f)
.DEFAULT_GOAL := help

header = $(call tprint,{c.b_magenta}==>{c.end} {c.bold}$(1){c.end} {c.b_magenta}<=={c.end})

## bootstrap | generate local conda environment
.PHONY: bootstrap
bootstrap:
	$(call header,Bootstrap Environment)
	@mamba create -p ./env python jinja2 black

## lint | lint the python
.PHONY: lint
lint:
	@black generate.py
	@black src/*.py --fast

## release | make new release of project
.PHONY: release
release: version-check
	$(call header,Release Project)
	@./generate.py $(VERSION) > task.mk
	@sed -i 's/task.mk\/.*\/task.mk/task.mk\/v$(VERSION)\/task.mk/g' README.md
	@git add task.mk README.md
	@git commit -m "release: v$(VERSION)"

## clean | remove the generated files
.PHONY: clean
clean:
	@rm -f task.mk .task.mk


.PHONY: version-check
version-check:
	@if [[ "${VERSION}" == *'-'* ]]; then\
		$(call tprint-sh,{c.red}VERSION INVALID! Uncommited Work{c.end});\
		echo ">> version: $(VERSION)"; exit 1;\
	elif [[ $(shell echo "${VERSION}" | awk -F. '{ print NF }') -lt 3 ]];then\
		$(call tprint-sh,{c.red}VERSION INVALID! Expected CalVer string{c.end});\
		echo ">> version: $(VERSION)"; exit 1;\
	else \
		$(call tprint-sh,{c.green}VERSION LOOKS GOOD!{c.end});\
	fi

define msg
{c.b_yellow}
It can even be multiline!{c.end}
and styles can be defined{c.end}
as python {c.bold}f-string{c.end} literals
{c.end}
endef

## info | demonstarte usage of tprint
.PHONY: task
info:
	$(call header, Info Message)
	$(call tprint,{c.b_magenta}This is task-print output:{c.end})
	$(call tprint,$(msg))


define USAGE
{c.$(HEADER_COLOR)}usage:{c.end}
	make <recipe>

A usage statement...with {c.b_green}COLOR{c.end}

endef

EPILOG = \nAn epilog...\nfor more help: see github.com/daylinmorgan/task.mk
PRINT_VARS := VERSION

-include .task.mk
.task.mk: $(TEMPLATES) generate.py
	./generate.py $(VERSION) > .task.mk
