msgfmt = {a.style('==>','bold')} {a.style('$(1)','b_magenta')} {a.style('<==','bold')}
msg = $(call tprint,$(call msgfmt ,$(1)))

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

# dollar signs will always be a problem
define bash_script
echo "Is the process running bash? We can check with ps"
ps -o args= -p $$$$ | grep -E -m 1 -o '\w{0,5}sh'
if [ -x "$(command -v figlet)" ]; then
	echo 'no figlet :('
else
	echo "What text to figlet? "
	read name
	figlet $$name
fi
echo "the argument below as given in the makefile itself"
echo "it's expanded before the script is passed to bash"
printf "%s\n" "$(2)"
endef

## embedded-bash | bash script with pipes and make input
.PHONY: embedded-bash
embedded-bash:
	$(call tbash,bash_script,bash multiline is probably working)

define mlmsg
{a.b_yellow}
It can even be multiline!{a.end}
{a.style('and styles can be defined','red')}
as python {a.bold}f-string{a.end} literals
{a.end}
endef

define USAGE
{a.$(HEADER_STYLE)}usage:{a.end}
	make <recipe>
	
	examples of embedded scripts in `{a.magenta}Makefile{a.end}`

endef
.DEFUALT_GOAL = help
include $(shell git rev-parse --show-toplevel)/task.mk

