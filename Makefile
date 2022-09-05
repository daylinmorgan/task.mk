VERSION ?= $(shell git describe --tags --always --dirty | sed s'/dirty/dev/')
TEMPLATES := $(shell find src/ -type f)
.DEFAULT_GOAL := help

header = $(call tprint,{a.b_magenta}==>{a.end} {a.bold}$(1){a.end} {a.b_magenta}<=={a.end})

## bootstrap | generate local dev environment
.PHONY: bootstrap
bootstrap:
	$(call header,Bootstrap Environment)
	@mamba create -p ./env python jinja2 black -y
	@mamba run -p ./env pip install yartsu

## lint | lint the python
.PHONY: lint
lint:
	@black generate.py
	@black src/*.py --fast

## assets | generate assets
.PHONY: assets
assets:
	yartsu -o assets/help.svg -t "make help" -- make --no-print-directory help

define list_files_py
from pathlib import Path
print("files in $(2)")
print([f.name for f in (Path("$(2)").iterdir())])
endef

## list-% | use pathlib.Path to list files
list-%:
	$(call py,list_files_py,$*)

## release | release new version of task.mk
.PHONY: release
release: version-check
	$(call header,Release Project)
	@./generate.py $(VERSION) > task.mk
	@sed -i 's/task.mk\/.*\/task.mk/task.mk\/v$(VERSION)\/task.mk/g' README.md
	@git add task.mk README.md
	@git commit -m "release: v$(VERSION)"

## c, clean | remove the generated files
.PHONY: clean
c clean:
	@rm -f task.mk .task.mk

.PHONY: version-check
version-check:
	@if [[ "${VERSION}" == *'-'* ]]; then\
		$(call tprint-sh,{a.red}VERSION INVALID! Uncommited Work{a.end});\
		echo ">> version: $(VERSION)"; exit 1;\
	elif [[ $(shell echo "${VERSION}" | awk -F. '{ print NF }') -lt 3 ]];then\
		$(call tprint-sh,{a.red}VERSION INVALID! Expected CalVer string{a.end});\
		echo ">> version: $(VERSION)"; exit 1;\
	else \
		$(call tprint-sh,{a.green}VERSION LOOKS GOOD!{a.end});\
	fi

define msg
{a.b_yellow}
It can even be multiline!{a.end}
and styles can be defined{a.end}
as python {a.bold}f-string{a.end} literals
{a.end}
endef

## info | demonsrtate usage of tprint
.PHONY: task
info:
	$(call header, Info Message)
	$(call tprint,{a.b_magenta}This is task-print output:{a.end})
	$(call tprint,$(msg))


define USAGE
{a.$(HEADER_COLOR)}usage:{a.end}
	make <recipe>

  Turn your {a.b_magenta}`Makefile`{a.end} into
  the {a.italic}{a.underline}task runner{a.end} you always needed.
  See the example output below.

endef

EPILOG = \nfor more info: see github.com/daylinmorgan/task.mk
PRINT_VARS := VERSION

-include .task.mk
.task.mk: $(TEMPLATES) generate.py
	./generate.py $(VERSION) > .task.mk
