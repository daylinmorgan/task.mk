#% extends "py-script.mk" %#
#% block name %#utils#% endblock %#
#% block script %#
import os
import sys
from dataclasses import dataclass


@dataclass
class Config:
    div: str
    sep: str
    epilog: str
    usage: str
    wrap: int


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

addfg = lambda byte: byte + 30
addbg = lambda byte: byte + 40


class Ansi:
    """ANSI escape codes"""

    def __init__(self, target="stdout"):
        self.target = target
        self.setcode("end", "\033[0m")
        self.setcode("default", "\033[38m")
        self.setcode("bg_default", "\033[48m")
        for name, byte in color2byte.items():
            self.setcode(name, f"\033[{addfg(byte)}m")
            self.setcode(f"b_{name}", f"\033[1;{addfg(byte)}m")
            self.setcode(f"d_{name}", f"\033[2;{addfg(byte)}m")
            for bgname, bgbyte in color2byte.items():
                self.setcode(
                    f"{name}_on_{bgname}", f"\033[{addbg(bgbyte)};{addfg(byte)}m"
                )
        for name, byte in state2byte.items():
            self.setcode(name, f"\033[{byte}m")
        self.add_cfg()

    def setcode(self, name, escape_code):
        """create attr for style and escape code"""

        if os.getenv("NO_COLOR", False):
            setattr(self, name, "")
        elif (self.target == "stderr" and not sys.stderr.isatty()) or (
            self.target == "stdout" and not sys.stdout.isatty()
        ):
            setattr(self, name, "")
        else:
            setattr(self, name, escape_code)

    def custom(self, fg=None, bg=None):
        """use custom color"""

        code, end = "\033[", "m"
        if not sys.stdout.isatty() or os.getenv("NO_COLOR", False):
            return ""
        else:
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

    def add_cfg(self):
        cfg_styles = {
            "header": "$(HEADER_STYLE)",
            "accent": "$(ACCENT_STYLE)",
            "params": "$(PARAMS_STYLE)",
            "goal": "$(GOAL_STYLE)",
            "msg": "$(MSG_STYLE)",
            "div_style": "$(DIVIDER_STYLE)",
        }
        for name, style in cfg_styles.items():
            self.setcode(name, getattr(self, style))

    def style(self, text, style):
        if style not in self.__dict__:
            print(f"unknown style: {style}")
            sys.exit(1)
        else:
            return f"{self.__dict__[style]}{text}{self.__dict__['end']}"


a = ansi = Ansi()
cfg = Config(
    "$(DIVIDER)", "$(HELP_SEP)", f"""$(EPILOG)""", f"""$(USAGE)""", int("$(WRAP)")
)
#% endblock %#
