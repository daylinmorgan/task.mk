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

    def setcode(self, name, escape_code):
        """create attr for style and escape code"""

        if not sys.stdout.isatty() or os.getenv("NO_COLOR", False):
            setattr(self, name, "")
        else:
            setattr(self, name, escape_code)

    def custom(self, fg=None, bg=None):
        """use custom color"""

        code, end = "\033[", "m"
        if fg:
            if isinstance(fg, int):
                code += f"38;5;{fg}"
            elif (isinstance(fg, list) or isinstance(fg, tuple)) and len(fg) == 1:
                code += f"38;5;{fg[0]}"
            elif (isinstance(fg, list) or isinstance(fg, tuple)) and len(fg) == 3:
                code += f"38;2;{';'.join((str(i) for i in fg))}"
            else:
                print("Expected one or three values for fg as a list")
                sys.exit(1)

        if bg:
            if isinstance(bg, int):
                code += f"{';' if fg else ''}48;5;{bg}"
            elif (isinstance(bg, list) or isinstance(bg, tuple)) and len(bg) == 1:
                code += f"{';' if fg else ''}48;5;{bg[0]}"
            elif (isinstance(bg, list) or isinstance(bg, tuple)) and len(bg) == 3:
                code += f"{';' if fg else ''}48;2;{';'.join((str(i) for i in bg))}"
            else:
                print("Expected one or three values for bg as a list")
                sys.exit(1)

        return code + end


a = ansi = Ansi()
#% endblock %#
