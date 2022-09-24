#% extends "py-script.mk" %#
#% block name %#print_ansi#% endblock %#
#% block script %#
##- '$(utils_py)' -##
sep = f"$(HELP_SEP)"
codes_names = {getattr(ansi, attr): attr for attr in ansi.__dict__}
for code in sorted(codes_names.keys(), key=lambda item: (len(item), item)):
    print(f"{codes_names[code]:>20} {sep} {code+'*****'+ansi.end} {sep} {repr(code)}")

#% endblock %#
