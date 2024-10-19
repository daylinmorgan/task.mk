VERSION ?= $(shell git describe --tags --always --dirty=-dev)
TEMPLATES := $(shell find src/ -type f)
.DEFAULT_GOAL := help
msg = $(if $(tprint),$(call tprint,{a.bold}==> {a.magenta}$(1){a.end}),@echo '==> $(1)')

### task.mk development |> -d -ms b_green --align center
bootstrap: env hooks ## generate local dev environment |> -ms b_magenta -gs b_cyan
env: ##
	$(call msg,Bootstrapping Environment)
	@python -m venv .venv
	@./.venv/bin/pip install jinja2 black yartsu
hooks: ##
	@git config core.hooksPath .githooks
docs-env: ##
	@./.venv/bin/pip install -r ./requirements-docs.txt

l lint: ## lint the python
	$(call msg,Linting)
	@black generate.py
	@black src/*.py --fast

assets: ## generate assets
	@yartsu -o assets/help.svg -t "make help" -- make --no-print-directory help

define release_sh
./generate.py $(subst v,,$(VERSION)) > task.mk
sed -i 's/task.mk\/.*\/task.mk/task.mk\/$(VERSION)\/task.mk/g' README.md docs/index.md
sed -i 's/TASKMK_VERSION=.*/TASKMK_VERSION="$(VERSION)"/' docs/init
git add task.mk README.md docs/{index.md,init}
git commit -m "release: $(VERSION)" --no-verify
git tag $(VERSION)
endef

release: version-check ## release new version of task.mk
	$(call msg,Release Project)
	$(call tbash,release_sh)

c clean: ## remove the generated files
	@rm -f .task.mk

define version_check_sh
if git rev-parse -q --verify "refs/tags/${VERSION}" >/dev/null; then
	$(call tprint-verbose,{a.red}VERSION INVALID!{a.end} tag already exists); exit 1;
elif [[ "${VERSION}" == *'-'* ]]; then
	$(call tprint-verbose,{a.red}VERSION INVALID!{a.end} Uncommited or untagged work); exit 1;
	exit 1
fi
endef

version-check: ##
	@$(call tprint,>> version: {a.green}$(VERSION){a.end})
	@$(call tbash,version_check_sh)
	@$(call tprint,>> {a.green}VERSION LOOKS GOOD!{a.end})

info: ## demonstrate usage of tprint
	$(call msg,Info Message)
	$(call tprint,{a.black_on_cyan}This is task-print output:{a.end})
	$(call tprint,$(mlmsg))
	$(call tprint,{a.custom(fg=(148, 255, 15),bg=(103, 2, 15))}Custom Colors TOO!{a.end})

task.mk: $(TEMPLATES) generate.py
	./generate.py $(VERSION) > task.mk

-include .task.cfg.dev.mk .task.cfg.mk 
