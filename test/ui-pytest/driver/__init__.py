import squishtest  # noqa

import configs
from . import aut
from . import context
from . import objects_access
from . import server
from . import toplevel_window

imports = {module.__name__: module for module in [
    aut,
    context,
    objects_access,
    server,
    toplevel_window
]}


def __getattr__(name):
    if name in imports:
        return imports[name]
    return getattr(squishtest, name)


squishtest.testSettings.waitForObjectTimeout = configs.timeouts.UI_LOAD_TIMEOUT_MSEC
squishtest.setHookSubprocesses(True)
