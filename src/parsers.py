#% extends "py-script.mk" %#
#% block name %#parsers#% endblock %#
#% block script %#
import argparse

###- LSP TRICK ONLY
import os, re, sys

# -###

##- '$(utils_py)' -##

###- double dollar signs to prevent make escaping them -###
###- bets on how long until I break this regex? -###
pattern = re.compile(
    r"""
(?:
  ^\#\#\#\s+ # <- raw message
  |
  ^(?:
    (?:\#\#\s+)?
    (?P<goal>.*?)(?:\s+\|>|:.*?\#\#)\s?
  ) # <- a custom goal or actual recipe
)
(?P<msg>.*?)?\s? # <- help text (optional)
(?:\|>\s+
  (?P<msgargs>.*?)
)? # <- style args (optional)
$$
""",
    re.X,
)

goal_pattern = re.compile(r"""^(?!#|\t)(.*):.*\n\t""", re.MULTILINE)


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
            elif not any(match.groupdict().get(k) for k in ('msg','msgargs')):
                pass
            else:
                yield {k: v for k, v in match.groupdict().items() if v is not None}


def parseargs(argstring):
    parser = argparse.ArgumentParser()
    parser.add_argument("--align")
    parser.add_argument("-d", "--divider", action="store_true")
    parser.add_argument("-ws", "--whitespace", action="store_true")
    parser.add_argument("-ms", "--msg-style", type=str)
    parser.add_argument("-gs", "--goal-style", type=str)
    parser.add_argument("--hidden", action="store_true")
    parser.add_argument("--not-phony", action="store_true")
    return parser.parse_args(argstring.split())


#% endblock %#
