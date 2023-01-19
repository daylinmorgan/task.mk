VERSION ?= $(shell git describe --tags --always --dirty=dev)
TEMPLATES := $(shell find src/ -type f)
.DEFAULT_GOAL := help
msg = $(if $(tprint),$(call tprint,{a.bold}==> {a.magenta}$(1){a.end}),@echo '==> $(1)')


### task.mk development |> -d -ms b_green --align center
## bootstrap | generate local dev environment |> -ms b_magenta -gs b_cyan
.PHONY: bootstrap env hooks
bootstrap: env hooks
env: 
	$(call msg,Bootstrapping Environment)
	@mamba create -p ./env python jinja2 black -y
	@mamba run -p ./env pip install yartsu
hooks:
	@git config core.hooksPath .githooks
docs-env:
	@mamba run -p ./env pip install mkdocs-material mkdocs-git-revision-date-localized-plugin

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
	@./generate.py $(subst v,,$(VERSION)) > task.mk
	@sed -i 's/task.mk\/.*\/task.mk/task.mk\/$(VERSION)\/task.mk/g' README.md
	@sed -i 's/task.mk\/.*\/task.mk/task.mk\/$(VERSION)\/task.mk/g' docs/index.md
	@git add task.mk README.md docs/index.md
	@git commit -m "release: $(VERSION)" --no-verify
	@git tag v$(VERSION)

## c, clean | remove the generated files
.PHONY: clean
c clean:
	@rm -f task.mk .task.mk

define version_check_sh
if [[ "${VERSION}" == *'-'* ]]; then 
	$(call tprint-sh,{a.red}VERSION INVALID! Uncommited or untagged work{a.end})
	exit 1
elif [[ $(shell echo "${VERSION}" | awk -F. '{ print NF }') -lt 3 ]];then\
	$(call tprint-sh,{a.red}VERSION INVALID! Uncommited or untagged work{a.end})
	$(call tprint-sh,{a.red}VERSION INVALID! Expected CalVer string{a.end})
	exit 1
fi
endef

.PHONY: version-check
version-check:
	@$(call tprint,>> version: {a.green}$(VERSION){a.end})
	@$(call tbash,version_check_sh)
	@$(call tprint,>> {a.green}VERSION LOOKS GOOD!{a.end})

## info | demonstrate usage of tprint
.PHONY: task
info:
	$(call msg,Info Message)
	$(call tprint,{a.black_on_cyan}This is task-print output:{a.end})
	$(call tprint,$(mlmsg))
	$(call tprint,{a.custom(fg=(148, 255, 15),bg=(103, 2, 15))}Custom Colors TOO!{a.end})

task.mk: $(TEMPLATES) generate.py
	./generate.py $(VERSION) > task.mk

-include .task.mk
.task.mk: $(TEMPLATES) generate.py
	$(call msg,re-jinjaing the local .task.mk)
	@./generate.py $(VERSION) > .task.mk || (echo "generator failed!!" && rm .task.mk)
