#% extends "py-script.mk" %#
#% block name %#quit_make#% endblock %#
#% block script %#

import os, signal, sys


def quit_make():
    old_stdout = sys.stdout
    with open(os.devnull, "w") as f:
        sys.stdout = f
        os.kill(os.getppid(), signal.SIGQUIT)
    sys.stdout = old_stdout


#% endblock %#
