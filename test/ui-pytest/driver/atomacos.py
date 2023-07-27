import time
from copy import deepcopy

import configs.timeouts

if configs.system.IS_MAC:
    import atomacos

BUNDLE_ID = 'im.Status.NimStatusClient'


# https://pypi.org/project/atomacos/


def attach_atomac(timeout_sec: int = configs.timeouts.UI_LOAD_TIMEOUT_SEC):
    atomator = atomacos.getAppRefByBundleId(BUNDLE_ID)
    started_at = time.monotonic()
    while not hasattr(atomator, 'AXMainWindow'):
        time.sleep(1)
        assert time.monotonic() - started_at < timeout_sec, f'Attach error: {BUNDLE_ID}'
    return atomator


def find_object(object_name: dict):
    _object_name = deepcopy(object_name)
    if 'container' in _object_name:
        parent = find_object(_object_name['container'])
        del _object_name['container']
    else:
        return attach_atomac().windows()[0]

    assert parent is not None, f'Object not found: {object_name["container"]}'
    _object = parent.findFirst(**_object_name)
    assert _object is not None, f'Object not found: {_object_name}'
    return _object


def wait_for_object(object_name: dict, timeout_sec: int = configs.timeouts.UI_LOAD_TIMEOUT_SEC):
    started_at = time.monotonic()
    while True:
        try:
            return find_object(object_name)
        except AssertionError as err:
            if time.monotonic() - started_at > timeout_sec:
                raise LookupError(f'Object: {object_name} not found. Error: {err}')
