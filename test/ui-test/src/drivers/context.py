import configs
import squish
import time


def detach():
    for ctx in squish.applicationContextList():
        ctx.detach()
        assert squish.waitFor(
            lambda: not ctx.isRunning, configs.squish.PROCESS_LOAD_TIMEOUT_MSEC), 'Detach application failed'
        # TODO: close by ctx.pid and then detach
        time.sleep(5)
