import squishtest  # noqa

import configs
from . import objects_access
from . import toplevel_window

imports = {module.__name__: module for module in [
    objects_access,
    toplevel_window
]}


def __getattr__(name):
    if name in imports:
        return imports[name]
    return getattr(squishtest, name)


squishtest.testSettings.waitForObjectTimeout = configs.timeouts.UI_LOAD_TIMEOUT_MSEC
squishtest.setHookSubprocesses(True)
