#% extends "py-script.mk" %#
#% block name %#help#% endblock %#
#% block script %#
import argparse
from collections import namedtuple
import os
import re
import subprocess
import sys
from textwrap import wrap

###-
# this is just to trick the LSP during development
from utils import Ansi, cfg

# -###
##- '$(utils_py)' -##

a = ansi = Ansi(target="stdout")
MaxLens = namedtuple("MaxLens", "goal msg")

###- double dollar signs to prevent make escaping them -###
pattern = re.compile(
    r"^## (?P<goal>.*?) \| (?P<msg>.*?)(?:\s?\| args: (?P<msgargs>.*?))?$$|^### (?P<rawmsg>.*?)?(?:\s?\| args: (?P<rawargs>.*?))?$$"
)
goal_pattern = re.compile(r"""^(?!#|\t)(.*):.*\n\t""", re.MULTILINE)


def parseargs(argstring):
    parser = argparse.ArgumentParser()
    parser.add_argument("--align")
    parser.add_argument("-d", "--divider", action="store_true")
    parser.add_argument("-ws", "--whitespace", action="store_true")
    parser.add_argument("-ms", "--msg-style", type=str)
    parser.add_argument("-gs", "--goal-style", type=str)
    parser.add_argument("--hidden", action="store_true")
    return parser.parse_args(argstring.split())


def divider(len):
    return ansi.style(f"  {cfg.div*len}", "div_style")


def gen_makefile():
    makefile = ""
    for file in os.getenv("MAKEFILE_LIST", "").split():
        with open(file, "r") as f:
            makefile += f.read() + "\n\n"
    return makefile


def parse_help(file, hidden=False):
    for line in file.splitlines():
        match = pattern.search(line)
        if match:
            if (
                not hidden
                and not os.getenv("SHOW_HIDDEN")
                and str(match.groupdict().get("goal")).startswith("_")
            ):
                pass
            else:
                yield {k: v for k, v in match.groupdict().items() if v is not None}


def recipe_help_header(goal):
    item = [
        i
        for i in list(parse_help(gen_makefile(), hidden=True))
        if "goal" in i and goal == i["goal"]
    ]
    if item:
        return fmt_goal(
            item[0]["goal"],
            item[0]["msg"],
            len(item[0]["goal"]),
            item[0].get("msgargs", ""),
        )
    else:
        return f"  {ansi.style(goal,'goal')}"


def get_goal_deps(goal="task.mk"):
    make = os.getenv("MAKE", "make")
    cmd = [make, "-p", "-n", "-i"]
    for file in os.getenv("TASK_MAKEFILE_LIST", "").split():
        cmd.extend(["-f", file])
    database = subprocess.check_output(cmd, universal_newlines=True)
    dep_pattern = re.compile(r"^" + goal + ":(.*)?")
    for line in database.splitlines():
        match = dep_pattern.search(line)
        if match and match.groups()[0]:
            return wrap(
                f"{ansi.style('deps','default')}: {ansi.style(match.groups()[0].strip(),'msg')}",
                width=cfg.wrap,
                initial_indent="  ",
                subsequent_indent="  ",
            )


def parse_goal(file, goal):
    goals = goal_pattern.findall(file)
    matched_goal = [i for i in goals if goal in i.split()]
    output = []
    if matched_goal:
        output.append(recipe_help_header(matched_goal[0]))
        deps = get_goal_deps(matched_goal[0])
        if deps:
            output.extend(deps)
        lines = file.splitlines()
        loc = [n for n, l in enumerate(lines) if l.startswith(f"{matched_goal[0]}:")][0]
        recipe = []

        for line in lines[loc + 1 :]:
            if not line.startswith("\t"):
                break
            recipe.append(f"  {line.strip()}")
        output.append(divider(max((len(l.strip()) for l in recipe))))
        output.append("\n".join(recipe))
    else:
        deps = get_goal_deps(goal)
        if deps:
            output.append(recipe_help_header(goal))
            output.extend(deps)

    if not output:
        output.append(f"{ansi.style('ERROR','b_red')}: Failed to find goal: {goal}")
    return output


def fmt_goal(goal, msg, max_goal_len, argstr):
    args = parseargs(argstr)
    goal_style = args.goal_style.strip() if args.goal_style else "goal"
    msg_style = args.msg_style.strip() if args.msg_style else "msg"
    return (
        ansi.style(f"  {goal:>{max_goal_len}}", goal_style)
        + f" $(HELP_SEP) "
        + ansi.style(msg, msg_style)
    )


def fmt_rawmsg(msg, argstr, maxlens):
    args = parseargs(argstr)
    lines = []
    msg_style = args.msg_style.strip() if args.msg_style else "msg"
    if not os.getenv("SHOW_HIDDEN") and args.hidden:
        return []
    if msg:
        if args.align == "sep":
            lines.append(
                f"{' '*(maxlens.goal+len(cfg.sep)+4)}{ansi.style(msg,msg_style)}"
            )
        elif args.align == "center":
            lines.append(f"  {ansi.style(msg.center(sum(maxlens)),msg_style)}")
        else:
            lines.append(f"  {ansi.style(msg,msg_style)}")
    if args.divider:
        lines.append(divider(len(cfg.sep) + sum(maxlens) + 2))
    if args.whitespace:
        lines.append("\n")

    return lines


def print_help():
    lines = [cfg.usage]

    items = list(parse_help(gen_makefile()))
    maxlens = MaxLens(
        *(max((len(item[x]) for item in items if x in item)) for x in ["goal", "msg"])
    )
    for item in items:
        if "goal" in item:
            lines.append(
                fmt_goal(
                    item["goal"], item["msg"], maxlens.goal, item.get("msgargs", "")
                )
            )
        if "rawmsg" in item:
            lines.extend(fmt_rawmsg(item["rawmsg"], item.get("rawargs", ""), maxlens))
    lines.append(cfg.epilog)
    print("\n".join(lines))


def print_arg_help(help_args):
    print(f"{ansi.style('task.mk recipe help','header')}\n")
    for arg in help_args.split():
        print("\n".join((*parse_goal(gen_makefile(), arg),'\n')))


def main():
    help_args = os.getenv("HELP_ARGS")
    if help_args:
        print_arg_help(help_args)
        print(f"{ansi.faint}exiting task.mk{ansi.end}")
        sys.exit(1)
    else:
        print_help()


if __name__ == "__main__":
    main()

#% endblock %#
