#% extends "py-script.mk" %#
#% block name %#confirm#% endblock %#
#% block script %#

import sys

###-
# this is just to trick the LSP during development
from utils import a

# -###
##- '$(utils_py)' -##


def confirm():
    """
    Ask user to enter Y or N (case-insensitive).
    :return: True if the answer is Y.
    :rtype: bool
    """
    answer = ""
    while answer not in ["y", "n"]:
        sys.stderr.write(f"""$(2) {a.b_red}[Y/n]{a.end} \n""")
        answer = input().lower()
    return answer == "y"


if confirm():
    sys.exit()
else:
    sys.exit(1)
#% endblock %#
