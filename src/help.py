#% extends "py-script.mk" %#
#% block name %#help#% endblock %#
#% block script %#
import argparse
from collections import namedtuple
import os
import re

##- '$(ansi_py)' -##

MaxLens = namedtuple("MaxLens", "goal msg")

# double dollar signs to prevent make escaping them
pattern = re.compile(
    r"^## (?P<goal>.*) \| (?P<msg>.*)|^### (?P<rawmsg>.*?)?(?:\s?\| args: (?P<args>.*?))?$$"
)


def rawargs(argstring):
    parser = argparse.ArgumentParser()
    parser.add_argument("-a", "--align")
    parser.add_argument("-d", "--divider", action="store_true")
    return parser.parse_known_args(argstring.split())


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


def print_goal(goal, msg, max_goal_len):
    print(
        f"  {ansi.$(GOAL_COLOR)}{goal:>{max_goal_len}}{ansi.end}"
        " $(HELP_SEP) "
        f"{ansi.$(MSG_COLOR)}{msg}{ansi.end}"
    )


def print_rawmsg(msg, argstr, maxlens):
    args, unknown = rawargs(argstr)
    if msg:
        if args.align == "sep":
            print(
                f"{' '*(maxlens.goal+len('$(HELP_SEP)')+4)}{ansi.$(MSG_COLOR)}{msg}{ansi.end}"
            )
        elif args.align == "center":
            print(f"  {ansi.$(MSG_COLOR)}{msg.center(sum(maxlens))}{ansi.end}")
        else:
            print(f"  {ansi.$(MSG_COLOR)}{msg}{ansi.end}")
    if args.divider:
        print(
            f"{ansi.$(DIVIDER_COLOR)}  {'─'*(len('$(HELP_SEP)')+sum(maxlens)+2)}{ansi.end}"
        )


def print_help():
    print(f"""$(USAGE)""")

    items = list(parse_make(gen_makefile()))
    maxlens = MaxLens(
        *(max((len(item[x]) for item in items if x in item)) for x in ["goal", "msg"])
    )

    for item in items:
        if "goal" in item:
            print_goal(item["goal"], item["msg"], maxlens.goal)
        if "rawmsg" in item:
            print_rawmsg(item["rawmsg"], item.get("args", ""), maxlens)
        if len(item) == 1 and "args" in item:
            args, unknown = rawargs(item["args"])
            if args.divider:
                print(
                    "  " + "─" * (len("$(HELP_SEP)") + maxlens.goal + maxlens.msg + 2)
                )

    print(f"""$(EPILOG)""")


print_help()
#% endblock %#
