VERSION ?= $(shell git describe --tags --always --dirty | sed s'/dirty/dev/')
TEMPLATES := $(shell find src/ -type f)
.DEFAULT_GOAL := help

msgfmt = {a.style('==>','bold')} {a.style('$(1)','b_magenta')} {a.style('<==','bold')}
msg = $(call tprint,$(call msgfmt ,$(1)))

### task.mk development | args: -d -ms b_green --align center
## bootstrap | generate local dev environment
.PHONY: bootstrap
bootstrap:
	$(call msg,Bootstrap Environment)
	@mamba create -p ./env python jinja2 black -y
	@mamba run -p ./env pip install yartsu
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
	@git add task.mk README.md
	@git commit -m "release: v$(VERSION)" --no-verify
	@git tag v$(VERSION)

## c, clean | remove the generated files
.PHONY: clean
c clean:
	@rm -f task.mk .task.mk

### | args: --divider --whitespace
### examples of task.mk features | args: --divider --align center --msg-style b_red
define list_files_py
from pathlib import Path
print("files in $(2)")
print([f.name for f in (Path("$(2)").iterdir())])
endef

## list-% | use pathlib.Path to list files
### name the directory in rule (make list-src) | args: --align sep
list-%:
	$(call py,list_files_py,$*)

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


define bash_script
figlet task.mk 2>/dev/null || echo 'no figlet :('
echo "This is from bash"
cat /etc/hostname
printf "%s\n" "$(2)"
endef
.PHONY: test-bash
test-bash:
	$(call tbash,bash_script,bash multiline is probably working)

define mlmsg
{a.b_yellow}
It can even be multiline!{a.end}
{a.style('and styles can be defined','red')}
as python {a.bold}f-string{a.end} literals
{a.end}
endef

## info | demonstrate usage of tprint
.PHONY: task
info:
	$(call msg,Info Message)
	$(call tprint,{a.black_on_cyan}This is task-print output:{a.end})
	$(call tprint,$(mlmsg))
	$(call tprint,{a.custom(fg=(148, 255, 15),bg=(103, 2, 15))}Custom Colors TOO!{a.end})

.PHONY: check
check:
	$(call tconfirm,Would you like to proceed?)
	@echo "you said yes!"

### | args: --divider

task.mk: $(TEMPLATES) generate.py
	./generate.py $(VERSION) > task.mk

define USAGE
{a.$(HEADER_COLOR)}usage:{a.end}
	make <recipe>

  Turn your {a.style('`Makefile`','b_magenta')} into
  the {a.italic}{a.underline}task runner{a.end} you always needed.
  See the example output below.

endef

EPILOG = \nfor more info: github.com/daylinmorgan/task.mk
PRINT_VARS := VERSION

-include .task.mk
.task.mk: $(TEMPLATES) generate.py
	$(call tprint,{a.b_yellow}re-jinjaing the local .task.mk{a.end})
	@./generate.py $(VERSION) > .task.mk || (echo "generator failed!!" && rm .task.mk)
