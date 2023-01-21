#% extends "py-script.mk" %#
#% block name %#phonify#% endblock %#
#% block script %#

##- '$(utils_py)' -##
##- '$(parsers_py)' -##


def main():
    items = " ".join((i["goal"] for i in parse_help(gen_makefile()) if "goal" in i))
    sys.stdout.write(".PHONY: " + items)


if __name__ == "__main__":
    main()

#% endblock %#
