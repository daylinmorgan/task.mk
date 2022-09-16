# }> [github.com/daylinmorgan/task.mk] <{ #
# Copyright (c) 2022 Daylin Morgan
# MIT License
# version: v22.9.14-12-g5a95a14-dev
#
# task.mk should be included at the bottom of your Makefile with `-include .task.mk`
# See below for the standard configuration options that should be set prior to including this file.
# You can update your .task.mk with `make _update-task.mk`
# ---- [config] ---- #
HEADER_STYLE ?= b_cyan
ACCENT_STYLE ?= b_yellow
PARAMS_STYLE ?= $(ACCENT_STYLE)
GOAL_STYLE ?= $(ACCENT_STYLE)
MSG_STYLE ?= faint
DIVIDER_STYLE ?= default
DIVIDER ?= ─
HELP_SEP ?= │
# python f-string literals
EPILOG ?=
USAGE ?={ansi.$(HEADER_STYLE)}usage{ansi.end}:\n  make <recipe>
# ---- [buitlin recipes] ---- #
## h, help | show this help
.PHONY: help h
help h:
	$(call py,help_py)
.PHONY: _help
_help: export SHOW_HIDDEN=true
_help: help
ifdef PRINT_VARS
$(foreach v,$(PRINT_VARS),$(eval export $(v)))
.PHONY: vars v
vars v:
	$(call py,vars_py,$(PRINT_VARS))
endif
### | args: -ws --hidden
### task.mk builtins: | args: -d --hidden
## _print-ansi | show all possible ansi color code combinations
.PHONY:
_print-ansi:
	$(call py,print_ansi_py)
# functions to take f-string literals and pass to python print
tprint = $(call py,info_py,$(1))
tprint-sh = $(call pysh,info_py,$(1))
tconfirm = $(call py,confirm_py,$(1))
## _update-task.mk | downloads latest development version of task.mk
_update-task.mk:
	$(call tprint,{a.b_cyan}Updating task.mk{a.end})
	curl https://raw.githubusercontent.com/daylinmorgan/task.mk/main/task.mk -o .task.mk
export MAKEFILE_LIST
# ---- [python/bash script runner] ---- #
define \n


endef
escape_shellstring = $(subst `,\`,$(subst ",\",$(subst $$,\$$,$(subst \,\\,$1))))
escape_printf = $(subst \,\\,$(subst %,%%,$1))
create_string = $(subst $(\n),\n,$(call escape_shellstring,$(call escape_printf,$1)))
printline = printf -- "<----------------------------------->\n"
ifdef DEBUG
define _debug_runner
@printf "$(1) Script:\n";$(printline);printf "$(call create_string,$(3))\n";$(printline)
@printf "$(call create_string,$(3))" | $(2)
endef
py = $(call _debug_runner,Python,python3,$($(1)))
tbash = $(call _debug_runner,Bash,bash,$($(1)))
else
py = @python3 <(printf "$(call create_string,$($(1)))")
tbash = @bash <(printf "$(call create_string,$($(1)))")
endif
pysh = python3 <(printf "$(call create_string,$($(1)))")
# ---- [python scripts] ---- #
define  help_py
import argparse
from collections import namedtuple
import os
import re
from typing import Any
$(ansi_py)
ansi: Any
MaxLens = namedtuple("MaxLens", "goal msg")
# double dollar signs to prevent make escaping them
pattern = re.compile(
    r"^## (?P<goal>.*?) \| (?P<msg>.*?)(?:\s?\| args: (?P<msgargs>.*?))?$$|^### (?P<rawmsg>.*?)?(?:\s?\| args: (?P<rawargs>.*?))?$$"
)
def parseargs(argstring):
    parser = argparse.ArgumentParser()
    parser.add_argument("--align")
    parser.add_argument("-d", "--divider", action="store_true")
    parser.add_argument("-ws", "--whitespace", action="store_true")
    parser.add_argument("-ms", "--msg-style", type=str)
    parser.add_argument("-gs", "--goal-style", type=str)
    parser.add_argument("--hidden", action="store_true")
    return parser.parse_args(argstring.split())
def gen_makefile():
    makefile = ""
    for file in os.getenv("MAKEFILE_LIST").split():
        with open(file, "r") as f:
            makefile += f.read() + "\n\n"
    return makefile
def parse_make(file):
    for line in file.splitlines():
        match = pattern.search(line)
        if match:
            if not os.getenv("SHOW_HIDDEN") and str(
                match.groupdict().get("goal")
            ).startswith("_"):
                pass
            else:
                yield {k: v for k, v in match.groupdict().items() if v is not None}
def print_goal(goal, msg, max_goal_len, argstr):
    args = parseargs(argstr)
    goal_style = args.goal_style.strip() if args.goal_style else "$(GOAL_STYLE)"
    msg_style = args.msg_style.strip() if args.msg_style else "$(MSG_STYLE)"
    print(
        ansi.style(f"  {goal:>{max_goal_len}}", goal_style)
        + " $(HELP_SEP) "
        + ansi.style(msg, msg_style)
    )
def print_rawmsg(msg, argstr, maxlens):
    args = parseargs(argstr)
    msg_style = args.msg_style.strip() if args.msg_style else "$(MSG_STYLE)"
    if not os.getenv("SHOW_HIDDEN") and args.hidden:
        return
    if msg:
        if args.align == "sep":
            print(
                f"{' '*(maxlens.goal+len('$(HELP_SEP)')+4)}{ansi.style(msg,msg_style)}"
            )
        elif args.align == "center":
            print(f"  {ansi.style(msg.center(sum(maxlens)),msg_style)}")
        else:
            print(f"  {ansi.style(msg,msg_style)}")
    if args.divider:
        print(
            ansi.style(
                f"  {'$(DIVIDER)'*(len('$(HELP_SEP)')+sum(maxlens)+2)}",
                "$(DIVIDER_STYLE)",
            )
        )
    if args.whitespace:
        print()
def print_help():
    print(f"""$(USAGE)""")
    items = list(parse_make(gen_makefile()))
    maxlens = MaxLens(
        *(max((len(item[x]) for item in items if x in item)) for x in ["goal", "msg"])
    )
    for item in items:
        if "goal" in item:
            print_goal(item["goal"], item["msg"], maxlens.goal, item.get("msgargs", ""))
        if "rawmsg" in item:
            print_rawmsg(item["rawmsg"], item.get("rawargs", ""), maxlens)
    print(f"""$(EPILOG)""")
print_help()
endef
define  ansi_py
import os
import sys
color2byte = dict(
    black=0,
    red=1,
    green=2,
    yellow=3,
    blue=4,
    magenta=5,
    cyan=6,
    white=7,
)
state2byte = dict(
    bold=1, faint=2, italic=3, underline=4, blink=5, fast_blink=6, crossed=9
)
addfg = lambda byte: byte + 30
addbg = lambda byte: byte + 40
class Ansi:
    """ANSI escape codes"""
    def __init__(self):
        self.setcode("end", "\033[0m")
        self.setcode("default", "\033[38m")
        self.setcode("bg_default", "\033[48m")
        for name, byte in color2byte.items():
            self.setcode(name, f"\033[{addfg(byte)}m")
            self.setcode(f"b_{name}", f"\033[1;{addfg(byte)}m")
            self.setcode(f"d_{name}", f"\033[2;{addfg(byte)}m")
            for bgname, bgbyte in color2byte.items():
                self.setcode(
                    f"{name}_on_{bgname}", f"\033[{addbg(bgbyte)};{addfg(byte)}m"
                )
        for name, byte in state2byte.items():
            self.setcode(name, f"\033[{byte}m")
    def setcode(self, name, escape_code):
        """create attr for style and escape code"""
        if not sys.stdout.isatty() or os.getenv("NO_COLOR", False):
            setattr(self, name, "")
        else:
            setattr(self, name, escape_code)
    def custom(self, fg=None, bg=None):
        """use custom color"""
        code, end = "\033[", "m"
        if fg:
            if isinstance(fg, int):
                code += f"38;5;{fg}"
            elif (isinstance(fg, list) or isinstance(fg, tuple)) and len(fg) == 1:
                code += f"38;5;{fg[0]}"
            elif (isinstance(fg, list) or isinstance(fg, tuple)) and len(fg) == 3:
                code += f"38;2;{';'.join((str(i) for i in fg))}"
            else:
                print("Expected one or three values for fg as a list")
                sys.exit(1)
        if bg:
            if isinstance(bg, int):
                code += f"{';' if fg else ''}48;5;{bg}"
            elif (isinstance(bg, list) or isinstance(bg, tuple)) and len(bg) == 1:
                code += f"{';' if fg else ''}48;5;{bg[0]}"
            elif (isinstance(bg, list) or isinstance(bg, tuple)) and len(bg) == 3:
                code += f"{';' if fg else ''}48;2;{';'.join((str(i) for i in bg))}"
            else:
                print("Expected one or three values for bg as a list")
                sys.exit(1)
        return code + end
    def style(self, text, style):
        if style not in self.__dict__:
            print(f"unknown style: {style}")
            sys.exit(1)
        else:
            return f"{self.__dict__[style]}{text}{self.__dict__['end']}"
a = ansi = Ansi()
endef
define  info_py
$(ansi_py)
print(f"""$(2)""")
endef
define  print_ansi_py
$(ansi_py)
codes_names = {getattr(ansi, attr): attr for attr in ansi.__dict__}
for code in sorted(codes_names.keys(), key=lambda item: (len(item), item)):
    print(
        "{:>20} $(HELP_SEP) {} $(HELP_SEP) {}".format(
            codes_names[code], code + "******" + ansi.end, repr(code)
        )
    )
endef
define  vars_py
import os
$(ansi_py)
vars = "$2".split()
length = max((len(v) for v in vars))
print(f"{ansi.$(HEADER_STYLE)}vars:{ansi.end}\n")
for v in vars:
    print(f"  {ansi.b_magenta}{v:<{length}}{ansi.end} = {os.getenv(v)}")
print()
endef
define  confirm_py
import sys
$(ansi_py)
def confirm():
    """
    Ask user to enter Y or N (case-insensitive).
    :return: True if the answer is Y.
    :rtype: bool
    """
    answer = ""
    while answer not in ["y", "n"]:
        answer = input(f"""$(2) {a.b_red}[Y/n]{a.end} """).lower()
    return answer == "y"
if confirm():
    sys.exit(0)
else:
    sys.exit(1)
endef
