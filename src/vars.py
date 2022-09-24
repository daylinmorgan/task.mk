#% extends "py-script.mk" %#
#% block name %#vars#% endblock %#
#% block script %#
import os

##- '$(utils_py)' -##

vars = "$2".split()
length = max((len(v) for v in vars))

print(f"{ansi.header}vars{ansi.end}:\n")

for v in vars:
    print(f"  {ansi.params}{v:<{length}}{ansi.end} = {os.getenv(v)}")

print()
#% endblock %#
