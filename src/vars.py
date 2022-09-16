#% extends "py-script.mk" %#
#% block name %#vars#% endblock %#
#% block script %#
import os

##- '$(ansi_py)' -##

vars = "$2".split()
length = max((len(v) for v in vars))

print(f"{ansi.$(HEADER_STYLE)}vars:{ansi.end}\n")

for v in vars:
    print(f"  {ansi.b_magenta}{v:<{length}}{ansi.end} = {os.getenv(v)}")

print()
#% endblock %#
