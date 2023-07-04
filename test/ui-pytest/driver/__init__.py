import squishtest  # noqa

import configs

imports = {module.__name__: module for module in [
    # import any modules from driver folder
]}


def __getattr__(name):
    if name in imports:
        return imports[name]
    return getattr(squishtest, name)


squishtest.testSettings.waitForObjectTimeout = configs.timeouts.UI_LOAD_TIMEOUT_MSEC
squishtest.setHookSubprocesses(True)
