import time

import squish


def detach():
    for ctx in squish.applicationContextList():
        ctx.detach()
        # TODO: close by ctx.pid and then detach
        time.sleep(5)
