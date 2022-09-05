#% extends "py-script.mk" %#
#% block name %#ansi#% endblock %#
#% block script %#
import os
import sys

color2byte = dict(
    black=0,
    red=1,
    green=2,
    yellow=3,
    blue=4,
    magenta=5,
    cyan=6,
    white=7,
)

state2byte = dict(
    bold=1, faint=2, italic=3, underline=4, blink=5, fast_blink=6, crossed=9
)


def fg(byte):
    return 30 + byte


def bg(byte):
    return 40 + byte


class Ansi:
    """ANSI color codes"""

    def setcode(self, name, escape_code):
        if not sys.stdout.isatty() or os.getenv("NO_COLOR", False):
            setattr(self, name, "")
        else:
            setattr(self, name, escape_code)

    def __init__(self):
        self.setcode("end", "\033[0m")
        for name, byte in color2byte.items():
            self.setcode(name, f"\033[{fg(byte)}m")
            self.setcode(f"b_{name}", f"\033[1;{fg(byte)}m")
            self.setcode(f"d_{name}", f"\033[2;{fg(byte)}m")
            for bgname, bgbyte in color2byte.items():
                self.setcode(f"{name}_on_{bgname}", f"\033[{bg(bgbyte)};{fg(byte)}m")
        for name, byte in state2byte.items():
            self.setcode(name, f"\033[{byte}m")


a = ansi = Ansi()
#% endblock %#