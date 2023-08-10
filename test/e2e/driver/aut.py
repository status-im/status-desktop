import allure
import squish

import configs
import driver
from configs.system import IS_WIN, IS_LIN
from driver import context
from driver.server import SquishServer
from scripts.utils import system_path, local_system


class AUT:
    def __init__(
            self,
            app_path: system_path.SystemPath = configs.APP_DIR,
            host: str = '127.0.0.1',
            port: int = 61500
    ):
        super(AUT, self).__init__()
        self.path = app_path
        self.host = host
        self.port = int(port)
        self.ctx = None
        self.pid = None
        self.aut_id = self.path.name if IS_LIN else self.path.stem
        self.process_name = 'Status' if IS_WIN else 'nim_status_client'
        driver.testSettings.setWrappersForApplication(self.aut_id, ['Qt'])

    def __str__(self):
        return type(self).__qualname__

    @allure.step('Attach Squish to Test Application')
    def attach(self, timeout_sec: int = configs.timeouts.PROCESS_TIMEOUT_SEC, attempt: int = 2):
        if self.ctx is None:
            self.ctx = context.attach('AUT', timeout_sec)
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
            assert squish.waitFor(lambda: not self.ctx.isRunning, configs.timeouts.PROCESS_TIMEOUT_SEC)
        self.ctx = None
        return self

    @allure.step('Close application by process name')
    def stop(self):
        if configs.LOCAL_RUN:
            local_system.kill_process_by_pid(self.pid)
        else:
            local_system.kill_process_by_name(self.process_name)

    @allure.step("Start application")
    def launch(self, *args) -> 'AUT':
        SquishServer().set_aut_timeout()
        if configs.ATTACH_MODE:
            SquishServer().add_attachable_aut('AUT', self.port)
            command = [
                          configs.testpath.SQUISH_DIR / 'bin' / 'startaut',
                          f'--port={self.port}',
                          f'"{self.path}"'
                      ] + list(args)
            local_system.execute(command)
            try:
                local_system.wait_for_started(self.process_name)
            except AssertionError:
                local_system.execute(command, check=True)
        else:
            SquishServer().add_executable_aut(self.aut_id, self.path.parent)
            command = [self.aut_id] + list(args)
            self.ctx = squish.startApplication(
                ' '.join(command), configs.timeouts.PROCESS_TIMEOUT_SEC)

        self.attach()
        self.pid = self.ctx.pid
        assert squish.waitFor(lambda: self.ctx.isRunning, configs.timeouts.PROCESS_TIMEOUT_SEC)
        return self
