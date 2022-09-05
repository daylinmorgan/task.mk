#% extends "py-script.mk" %#
#% block name %#vars#% endblock %#
#% block script %#

import os

##- '$(color_py)' -##

vars = "$2".split()
length = max((len(v) for v in vars))

print(f"{color.$(HEADER_COLOR)}vars:{color.end}\n")

for v in vars:
    print(f"  {color.b_magenta}{v:<{length}}{color.end} = {os.getenv(v)}")

print()
#% endblock %#
