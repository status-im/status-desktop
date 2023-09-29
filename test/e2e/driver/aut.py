import logging
from datetime import datetime

import allure
import squish

import configs
import driver
from driver import context
from driver.server import SquishServer
from scripts.utils import system_path, local_system
from scripts.utils.system_path import SystemPath

_logger = logging.getLogger(__name__)


class AUT:
    def __init__(
            self,
            app_path: system_path.SystemPath = configs.APP_DIR,
            host: str = '127.0.0.1',
            port: int = configs.squish.AUT_PORT,
            user_data: SystemPath = None
    ):
        super(AUT, self).__init__()
        self.path = app_path
        self.host = host
        self.port = int(port)
        self.ctx = None
        self.pid = None
        self.aut_id = f'AUT_{datetime.now():%H%M%S}'
        self.app_data = configs.testpath.STATUS_DATA / f'app_{datetime.now():%H%M%S_%f}'
        if user_data is not None:
            user_data.copy_to(self.app_data / 'data')
        driver.testSettings.setWrappersForApplication(self.aut_id, ['Qt'])

    def __str__(self):
        return type(self).__qualname__

    def __enter__(self):
        return self.launch()

    def __exit__(self, *args):
        self.detach().stop()

    @allure.step('Attach Squish to Test Application')
    def attach(self, timeout_sec: int = configs.timeouts.PROCESS_TIMEOUT_SEC, attempt: int = 2):
        if self.ctx is None:
            self.ctx = context.attach(self.aut_id, timeout_sec)
        try:
            squish.setApplicationContext(self.ctx)
        except TypeError as err:
            if attempt:
                return self.attach(timeout_sec, attempt - 1)
            else:
                raise err

    @allure.step('Detach Squish and Application')
    def detach(self):
        if self.ctx is not None:
            squish.currentApplicationContext().detach()
        self.ctx = None
        return self

    @allure.step('Close application')
    def stop(self):
        local_system.kill_process(self.pid, verify=True)

    @allure.step("Start application")
    def launch(self, ) -> 'AUT':
        SquishServer().set_aut_timeout()

        if configs.ATTACH_MODE:
            while local_system.find_process_by_port(self.port):
                self.port += 1000
            SquishServer().add_attachable_aut(self.aut_id, self.port)
            command = [
                configs.testpath.SQUISH_DIR / 'bin' / 'startaut',
                f'--port={self.port}',
                f'"{self.path}"',
                f'-d={self.app_data}'
            ]
            local_system.execute(command)
            self.attach()
        else:
            SquishServer().add_executable_aut(self.aut_id, self.path.parent)
            command = [self.aut_id, f'-d={self.app_data}']
            self.ctx = squish.startApplication(' '.join(command), configs.timeouts.PROCESS_TIMEOUT_SEC)

        self.pid = self.ctx.pid
        assert squish.waitFor(lambda: self.ctx.isRunning, configs.timeouts.PROCESS_TIMEOUT_SEC)
        return self

    @allure.step('Restart application')
    def restart(self):
        self.detach().stop()
        self.launch()
