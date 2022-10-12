#% extends "py-script.mk" %#
#% block name %#print_ansi#% endblock %#
#% block script %#
##- '$(utils_py)' -##
import sys

codes_names = {getattr(ansi, attr): attr for attr in ansi.__dict__}
for code in sorted(codes_names.keys(), key=lambda item: (len(item), item)):
    sys.stderr.write(
        f"{codes_names[code]:>20} {cfg.sep} {code+'*****'+ansi.end} {sep} {repr(code)}\n"
    )

#% endblock %#
