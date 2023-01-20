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
###- $2 is a list of variables set by task.mk delimited with '<|>' -###
task_vars = tuple(v.split('=') for v in "$2".split('<|>'))
length = max((len(v[0]) for v in task_vars))
rows = (f"  {ansi.params}{v[0]:<{length}}{ansi.end} = {v[1]}" for v in task_vars)
print('\n'.join((f"{ansi.header}vars{ansi.end}:\n", *rows,'')))
#% endblock %#
