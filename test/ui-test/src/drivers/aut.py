from datetime import datetime

import configs
import squish
import time
import utils.FileManager as filesMngr
from utils import local_system
from drivers.elements.base_window import BaseWindow
from screens.main_window import MainWindow
from utils import local_system
from utils.system_path import SystemPath

from . import context


class AbstractAut:

    def __init__(self):
        self.ctx = None

    def __str__(self):
        return type(self).__qualname__
    
    def start(self, *args) -> 'AbstractAut':
        raise NotImplementedError

    def attach(self, aut_id: str = None, timeout_sec: int = configs.squish.PROCESS_TIMEOUT_SEC):
        if self.ctx is None or not self.ctx.isRunning:
            self.ctx = context.attach(aut_id, timeout_sec)
        squish.setApplicationContext(self.ctx)
        return self

    def detach(self):
        pid = self.ctx.pid
        squish.currentApplicationContext().detach()
        assert squish.waitFor(lambda: not self.ctx.isRunning, configs.squish.APP_LOAD_TIMEOUT_MSEC)
        assert squish.waitFor(lambda: pid not in local_system.get_pid(self.fp.name), configs.squish.APP_LOAD_TIMEOUT_MSEC)
        self.ctx = None
        return self


class ExecutableAut(AbstractAut):

    def __init__(self, fp: SystemPath):
        super(ExecutableAut, self).__init__()
        self.fp = fp

    def start(self, *args) -> 'ExecutableAut':
        cmd = ' '.join([self.fp.name] + [str(arg) for arg in args])
        self.ctx = squish.startApplication(cmd)
        local_system.wait_for_started(self.fp.stem)
        assert squish.waitFor(lambda: self.ctx.isRunning, configs.squish.APP_LOAD_TIMEOUT_MSEC)
        squish.setApplicationContext(self.ctx)
        return self

    def close(self):
        local_system.kill_process(self.fp.name)


class StatusAut(ExecutableAut):

    def __init__(self, fp: SystemPath, window: BaseWindow):
        super(StatusAut, self).__init__(fp)
        self._window = window
        self.app_data_dir = configs.path.TMP / f'{configs.path.STATUS_DATA_FOLDER_NAME}_{datetime.now():%H%M%S}'
        self.app_data_dir.mkdir(parents=True, exist_ok=True)

    @property
    def window(self) -> BaseWindow:
        assert self._window is not None, 'AUT has no window instance'
        return self._window

    def start(self, user_data: str = None, attempt: int = 2):
        if user_data is not None:
            user_data_dir = self.app_data_dir / 'data'
            user_data_dir.mkdir(parents=True, exist_ok=True)
            filesMngr.copy_directory(user_data, str(user_data_dir))
            
        try:
            super(StatusAut, self).start(f'--dataDir={self.app_data_dir}')
        except RuntimeError:
            if attempt:
                time.sleep(1)
                self.start(user_data, attempt-1)
            else:
                raise
            
        self.window.wait_until_appears().prepare()
        return self

    def restart(self):
        self.detach()
        self.start()


def start_application(ctx, fp: SystemPath = configs.path.AUT, user_data: str = None):
    for aut in ctx.userData.get('aut', []):
        if aut.ctx.isRunning:
            aut.attach().window.minimize()

    aut = StatusAut(fp, MainWindow()).start(user_data)
    ctx.userData['aut'].append(aut)


def restart_application(ctx, index: int = 0):
    aut = ctx.userData['aut'][index]
    aut.restart()

