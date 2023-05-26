import time

import configs
import squish


def attach(aut_name: str, timeout_sec: int = 30):
    print(f'Attaching squish to {aut_name}')
    started_at = time.monotonic()
    while True:
        try:
            context = squish.attachToApplication(aut_name)
            print(f'AUT: {aut_name} attached')
            return context
        except RuntimeError as err:
            print(err)
            time.sleep(1)
        assert time.monotonic() - started_at > timeout_sec, f'Attach error: {aut_name}'


def detach():
    for ctx in squish.applicationContextList():
        ctx.detach()
        assert squish.waitFor(
            lambda: not ctx.isRunning, configs.squish.PROCESS_TIMEOUT_MSEC), 'Detach application failed'
        # TODO: close by ctx.pid and then detach
        time.sleep(5)
