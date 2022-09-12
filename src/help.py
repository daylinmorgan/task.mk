#% extends "py-script.mk" %#
#% block name %#help#% endblock %#
#% block script %#
import os
import re

##- '$(ansi_py)' -##

pattern = re.compile(r"^## (.*) \| (.*)")

makefile = ""
for file in os.getenv("MAKEFILE_LIST").split():
    with open(file, "r") as f:
        makefile += f.read() + "\n\n"


def get_help(file):
    for line in file.splitlines():
        match = pattern.search(line)
        if match:
            if not os.getenv("SHOW_HIDDEN") and match.groups()[0].startswith("_"):
                continue
            else:
                yield match.groups()


print(f"""$(USAGE)""")

goals = list(get_help(makefile))
if os.getenv("SORT_HELP", False):
    goals.sort(key=lambda i: i[0])
goal_len = max(len(goal[0]) for goal in goals)

for goal, msg in goals:
    print(
        f"  {ansi.$(GOAL_COLOR)}{goal:>{goal_len}}{ansi.end} $(HELP_SEP) {ansi.$(MSG_COLOR)}{msg}{ansi.end}"
    )

print(f"""$(EPILOG)""")
#% endblock %#
