import time

import configs
import squish
import utils


def attach(aut_name: str, timeout_sec: int = configs.squish.PROCESS_TIMEOUT_SEC):
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
        assert time.monotonic() - started_at < timeout_sec, f'Attach error: {aut_name}'


def detach(timeout_sec: int = configs.squish.PROCESS_TIMEOUT_SEC):
    for ctx in squish.applicationContextList():
        started_at = time.monotonic()
        ctx.detach()
        while ctx.isRunning and time.monotonic() - started_at < timeout_sec:
            time.sleep(1)
