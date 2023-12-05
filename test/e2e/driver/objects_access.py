import logging
import time

import object
import squish

import configs

LOG = logging.getLogger(__name__)


def walk_children(parent, depth: int = 1000):
    for child in object.children(parent):
        yield child
        if depth:
            yield from walk_children(child, depth - 1)


def wait_for_template(
        real_name_template: dict, value: str, attr_name: str, timeout_sec: int = configs.timeouts.UI_LOAD_TIMEOUT_SEC):
    started_at = time.monotonic()
    while True:
        for obj in squish.findAllObjects(real_name_template):
            values = []
            if hasattr(obj, attr_name):
                current_value = str(getattr(obj, attr_name))
                if current_value == value:
                    return obj
                values.append(current_value)
            if time.monotonic() - started_at > timeout_sec:
                raise RuntimeError(f'Value not found in: {values}')
        time.sleep(1)
