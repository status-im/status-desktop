import configs
from utils.system_path import SystemPath

import squish
from . import context


class ExecutableAut:

    def __init__(self, fp: SystemPath):
        self.fp = fp
        self.ctx = None

    def start(self, *args, attempt: int = 2):
        args = ' '.join([self.fp.name] + [str(arg) for arg in args])
        try:
            self.ctx = squish.startApplication(args)
            assert squish.waitFor(lambda: self.ctx.isRunning, configs.squish.APP_LOAD_TIMEOUT_MSEC)
        except (AssertionError, RuntimeError):
            if attempt:
                self.detach()
                self.start(*args, attempt - 1)
            else:
                raise

    @staticmethod
    def detach():
        context.detach()
