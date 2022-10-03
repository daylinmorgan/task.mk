#% extends "py-script.mk" %#
#% block name %#print#% endblock %#
#% block script %#
##- '$(utils_py)' -##
###- sys is imported with utils_py -###
sys.stderr.write(f"""$(2)\n""")
#% endblock %#
