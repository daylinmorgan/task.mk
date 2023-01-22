#% extends "py-script.mk" %#
#% block name %#phonify#% endblock %#
#% block script %#

##- '$(utils_py)' -##
##- '$(parsers_py)' -##


def check_item(item):
    if not "goal" in item:
        return False
    args = parseargs(item.get("msgargs", ""))
    return not args.not_phony


def main():
    items = " ".join((i["goal"] for i in parse_help(gen_makefile()) if check_item(i)))
    sys.stdout.write(".PHONY: " + items)


if __name__ == "__main__":
    main()

#% endblock %#
