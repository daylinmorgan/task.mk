VERSION ?= $(shell git describe --tags --always --dirty | sed s'/dirty/dev/')
TEMPLATES := $(shell find src/ -type f)
.DEFAULT_GOAL := help

msg = $(if $(tprint),$(call tprint,{a.bold}==> {a.magenta}$(1){a.end}),@echo '==> $(1)')


### task.mk development | args: -d -ms b_green --align center
## bootstrap | generate local dev environment
.PHONY: bootstrap env hooks
bootstrap: env hooks
env: 
	$(call msg,Bootstrapping Environment)
	@mamba create -p ./env python jinja2 black -y
	@mamba run -p ./env pip install yartsu
hooks:
	@git config core.hooksPath .githooks

## l, lint | lint the python
.PHONY: l lint
l lint:
	$(call msg,Linting)
	@black generate.py
	@black src/*.py --fast

## assets | generate assets
.PHONY: assets
assets:
	@yartsu -o assets/help.svg -t "make help" -- make --no-print-directory help

## release | release new version of task.mk
.PHONY: release
release: version-check
	$(call msg,Release Project)
	@./generate.py $(VERSION) > task.mk
	@sed -i 's/task.mk\/.*\/task.mk/task.mk\/v$(VERSION)\/task.mk/g' README.md
	@sed -i 's/task.mk\/.*\/task.mk/task.mk\/v$(VERSION)\/task.mk/g' docs/index.md
	@git add task.mk README.md docs/index.md
	@git commit -m "release: v$(VERSION)" --no-verify
	@git tag v$(VERSION)

## c, clean | remove the generated files
.PHONY: clean
c clean:
	@rm -f task.mk .task.mk

.PHONY: version-check
version-check:
	@if [[ "${VERSION}" == *'-'* ]]; then\
		$(call tprint-sh,{a.red}VERSION INVALID! Uncommited or untagged work{a.end});\
		echo ">> version: $(VERSION)"; exit 1;\
	elif [[ $(shell echo "${VERSION}" | awk -F. '{ print NF }') -lt 3 ]];then\
		$(call tprint-sh,{a.red}VERSION INVALID! Expected CalVer string{a.end});\
		echo ">> version: $(VERSION)"; exit 1;\
	else \
		$(call tprint-sh,{a.green}VERSION LOOKS GOOD!{a.end});\
	fi

## info | demonstrate usage of tprint
.PHONY: task
info:
	$(call msg,Info Message)
	$(call tprint,{a.black_on_cyan}This is task-print output:{a.end})
	$(call tprint,$(mlmsg))
	$(call tprint,{a.custom(fg=(148, 255, 15),bg=(103, 2, 15))}Custom Colors TOO!{a.end})

task.mk: $(TEMPLATES) generate.py
	./generate.py $(VERSION) > task.mk

define USAGE
{a.style('usage','header')}:\n	make <recipe>\n
  Turn your {a.style('`Makefile`','b_magenta')} into
  the {a.italic}{a.underline}task runner{a.end} you always needed.
  See the example output below.\n
endef

EPILOG = \nfor more info: gh.dayl.in/task.mk
PRINT_VARS := VERSION SHELL
-include .task.mk
.task.mk: $(TEMPLATES) generate.py
	$(call msg,re-jinjaing the local .task.mk)
	@./generate.py $(VERSION) > .task.mk || (echo "generator failed!!" && rm .task.mk)
