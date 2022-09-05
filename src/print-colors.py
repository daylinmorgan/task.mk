#% extends "py-script.mk" %#
#% block name %#print_colors#% endblock %#
#% block script %#
##- '$(color_py)' -##

codes_names = {
    getattr(colors, attr): attr
    for attr in dir(colors)
    if attr[0:1] != "_" and attr != "end" and attr != "setcolor"
}
for code in sorted(codes_names.keys(), key=lambda item: (len(item), item)):
    print("{:>20} {}".format(codes_names[code], code + "******" + color.end))

#% endblock %#
