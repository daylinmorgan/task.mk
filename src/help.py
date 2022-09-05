#% extends "py-script.mk" %#
#% block name %#help#% endblock %#
#% block script %#
import os
import re

##- '$(color_py)' -##

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
goal_len = max(len(goal[0]) for goal in goals)

for goal, msg in goals:
    print(
        f"{color.$(GOAL_COLOR)}{goal:>{goal_len}}{color.end} $(HELP_SEP) {color.$(MSG_COLOR)}{msg}{color.end}"
    )

print(f"""$(EPILOG)""")
#% endblock %#
