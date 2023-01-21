#% extends "py-script.mk" %#
#% block name %#parsers#% endblock %#
#% block script %#
import re

###- LSP TRICK ONLY
import os, sys

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
            else:
                yield {k: v for k, v in match.groupdict().items() if v is not None}


#% endblock %#
