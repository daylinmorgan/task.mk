#% extends "py-script.mk" %#
#% block name %#print_ansi#% endblock %#
#% block script %#
##- '$(ansi_py)' -##

codes_names = {
    getattr(ansi, attr): attr
    for attr in dir(ansi)
    if attr[0:1] != "_" and attr != "end" and attr != "setcode"
}
for code in sorted(codes_names.keys(), key=lambda item: (len(item), item)):
    print("{:>20} {}".format(codes_names[code], code + "******" + ansi.end))

#% endblock %#
