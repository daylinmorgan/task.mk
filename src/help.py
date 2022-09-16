#% extends "py-script.mk" %#
#% block name %#help#% endblock %#
#% block script %#
import argparse
from collections import namedtuple
import os
import re
from typing import Any

##- '$(ansi_py)' -##
###- TODO: seperate parsing from printing -###
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
#% endblock %#
