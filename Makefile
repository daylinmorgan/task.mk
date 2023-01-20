VERSION ?= $(shell git describe --tags --always --dirty=-dev)
TEMPLATES := $(shell find src/ -type f)
.DEFAULT_GOAL := help
msg = $(if $(tprint),$(call tprint,{a.bold}==> {a.magenta}$(1){a.end}),@echo '==> $(1)')

### task.mk development |> -d -ms b_green --align center
.PHONY: bootstrap env hooks
bootstrap: env hooks ## generate local dev environment |> -ms b_magenta -gs b_cyan
env: 
	$(call msg,Bootstrapping Environment)
	@mamba create -p ./env python jinja2 black -y
	@mamba run -p ./env pip install yartsu
hooks:
	@git config core.hooksPath .githooks
docs-env:
	@mamba run -p ./env pip install mkdocs-material mkdocs-git-revision-date-localized-plugin

.PHONY: l lint
l lint: ## lint the python
	$(call msg,Linting)
	@black generate.py
	@black src/*.py --fast


.PHONY: assets
assets: ## generate assets
	@yartsu -o assets/help.svg -t "make help" -- make --no-print-directory help

define release_sh
./generate.py $(subst v,,$(VERSION)) > task.mk
sed -i 's/task.mk\/.*\/task.mk/task.mk\/$(VERSION)\/task.mk/g' README.md docs/index.md
git add task.mk README.md docs/index.md
git commit -m "release: $(VERSION)" --no-verify
git tag $(VERSION)
endef

.PHONY: release
release: version-check ## release new version of task.mk
	$(call msg,Release Project)
	$(call tbash,release_sh)

.PHONY: clean
c clean: ## remove the generated files
	@rm -f task.mk .task.mk

define version_check_sh
if git rev-parse -q --verify "refs/tags/${VERSION}" >/dev/null; then
	$(call tprint-verbose,{a.red}VERSION INVALID!{a.end} tag already exists); exit 1;
elif [[ "${VERSION}" == *'-'* ]]; then 
	$(call tprint-verbose,{a.red}VERSION INVALID!{a.end} Uncommited or untagged work); exit 1;
	exit 1
elif [[ $(shell echo "${VERSION}" | awk -F. '{ print NF }') -lt 3 ]];then\
	$(call tprint-verbose,{a.red}VERSION INVALID!{a.end} Expected CalVer string)
	exit 1
fi
endef

.PHONY: version-check
version-check:
	@$(call tprint,>> version: {a.green}$(VERSION){a.end})
	@$(call tbash,version_check_sh)
	@$(call tprint,>> {a.green}VERSION LOOKS GOOD!{a.end})

.PHONY: task
info: ## demonstrate usage of tprint
	$(call msg,Info Message)
	$(call tprint,{a.black_on_cyan}This is task-print output:{a.end})
	$(call tprint,$(mlmsg))
	$(call tprint,{a.custom(fg=(148, 255, 15),bg=(103, 2, 15))}Custom Colors TOO!{a.end})

task.mk: $(TEMPLATES) generate.py
	./generate.py $(VERSION) > task.mk

-include .task.cfg.mk .task.mk 
.task.mk: $(TEMPLATES) generate.py
	$(call msg,re-jinjaing the local .task.mk)
	@./generate.py $(VERSION) > .task.mk || (echo "generator failed!!" && rm .task.mk)
