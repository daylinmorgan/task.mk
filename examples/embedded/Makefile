### examples of task.mk features |> --divider --align center --msg-style b_red
define list_files_py
from pathlib import Path
print("files in $(2)")
print([f.name for f in (Path("$(2)").iterdir())])
endef

## list-% |> use pathlib.Path to list files
### name the directory in rule (make list-src) |> --align sep
list-%:
	$(call py,list_files_py,$*)

# dollar signs will always be a problem :|
define bash_script
echo "Is the process running bash? We can check with ps"
ps -o args= -p $$$$ | grep -E -m 1 -o '\w{0,5}sh'
echo "Get input at runtime"
printf "type input now! "
read -r name
echo "you typed -> $$name"
echo "the argument below as given in the makefile itself"
echo "it's expanded before the script is passed to bash"
printf "%s\n" "$(2)"
endef

.PHONY: embedded-bash
embedded-bash: ## bash script with pipes and make input
	$(call tbash,bash_script,bash multiline is working 🤞)

define USAGE
{a.$(HEADER_STYLE)}usage:{a.end}\n  make <recipe>\n\n  examples of embedded scripts in `{a.magenta}Makefile{a.end}`\n
endef

.DEFAULT_GOAL = help
include .task.mk
