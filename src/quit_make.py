#% extends "py-script.mk" %#
#% block name %#quit_make#% endblock %#
#% block script %#

import os, signal


def quit_make():
    os.kill(os.getppid(), signal.SIGQUIT)


#% endblock %#
