#% extends "py-script.mk" %#
#% block name %#vars#% endblock %#
#% block script %#

import os

##- '$(color_py)' -##

vars = "$2".split()
length = max((len(v) for v in vars))

print(f"{colors.$(HEADER_COLOR)}vars:{colors.end}\n")

for v in vars:
    print(f"  {colors.b_magenta}{v:<{length}}{colors.end} = {os.getenv(v)}")

print()
#% endblock %#
