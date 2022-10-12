#% extends "py-script.mk" %#
#% block name %#vars#% endblock %#
#% block script %#
import os

###-
# this is just to trick the LSP during development
from utils import Ansi

# -###
##- '$(utils_py)' -##


ansi = Ansi(target="stdout")
vars = "$2".split()
length = max((len(v) for v in vars))

print(f"{ansi.header}vars{ansi.end}:\n")

for v in vars:
    print(f"  {ansi.params}{v:<{length}}{ansi.end} = {os.getenv(v)}")

print()
#% endblock %#
