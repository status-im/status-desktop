import os
import time

import allure
import logging
import cv2
import numpy as np
import squish
from PIL import ImageGrab

import configs
import driver
import shortuuid
from datetime import datetime
from configs.system import get_platform
from driver import context
from driver.server import SquishServer
from gui.objects_map.names import statusDesktop_mainWindow
from scripts.utils import system_path, local_system
from scripts.utils.system_path import SystemPath
from scripts.utils.wait_for_port import wait_for_port

LOG = logging.getLogger(__name__)


class AUT:
    def __init__(
            self,
            app_path: system_path.SystemPath = configs.AUT_PATH,
            user_data: SystemPath = None
    ):
        self.path = app_path
        self.ctx = None
        self.pid = None
        self.port = None
        self.aut_id = f'AUT_{datetime.now():%H%M%S}'
        self.app_data = configs.testpath.STATUS_DATA / f'app_{shortuuid.ShortUUID().random(length=10)}'
        if user_data is not None:
            user_data.copy_to(self.app_data / 'data')
        self.options = ''
        driver.testSettings.setWrappersForApplication(self.aut_id, ['Qt'])

    def __str__(self):
        return type(self).__qualname__

    def __enter__(self):
        return self.launch()

    def __exit__(self, exc_type, exc_value, traceback):
        if exc_type:
            try:
                self.attach()
                driver.waitForObjectExists(statusDesktop_mainWindow).setVisible(True)
                configs.testpath.TEST.mkdir(parents=True, exist_ok=True)
                screenshot = configs.testpath.TEST / f'{self.aut_id}.png'

                rect = driver.object.globalBounds(driver.waitForObject(statusDesktop_mainWindow))
                img = ImageGrab.grab(
                    bbox=(rect.x, rect.y, rect.x + rect.width, rect.y + rect.height),
                    xdisplay=configs.system.DISPLAY if get_platform() == "Linux" else None)
                view = cv2.cvtColor(np.array(img), cv2.COLOR_BGR2RGB)
                cv2.imwrite(str(screenshot), view)

                allure.attach(
                    name=f'Screenshot on fail: {self.aut_id}',
                    body=screenshot.read_bytes(),
                    attachment_type=allure.attachment_type.PNG)
            except Exception as err:
                LOG.error(err)

        self.stop()

    def detach_context(self):
        if self.ctx is None:
            return
        driver.currentApplicationContext().detach()
        self.ctx = None

    @allure.step('Attach Squish to Test Application')
    def attach(self):
        LOG.info('Attaching to AUT: localhost:%d', self.port)

        try:
            SquishServer().add_attachable_aut(self.aut_id, self.port)
            if self.ctx is None:
                self.ctx = context.get_context(self.aut_id)
            driver.setApplicationContext(self.ctx)
            assert squish.waitFor(lambda: self.ctx.isRunning, configs.timeouts.PROCESS_TIMEOUT_SEC)
        except Exception as err:
            LOG.error('Failed to attach AUT: %s', err)
            self.stop()
            raise err
        LOG.info('Successfully attached AUT!')
        return self

    @allure.step('Start AUT')
    def startaut(self):
        LOG.info('Launching AUT: %s', self.path)
        self.port = local_system.find_free_port(configs.squish.AUT_PORT, 100)

        command = [
            str(configs.testpath.SQUISH_DIR / 'bin/startaut'),
            '--verbose',
            f'--port={self.port}',
            str(self.path),
            f'--datadir={self.app_data}',
            f'--LOG_LEVEL={configs.testpath.LOG_LEVEL}',
            '--api-logging'
        ]
        try:
            with open(configs.AUT_LOG_FILE, "ab") as log:
                self.pid = local_system.execute(command, stderr=log, stdout=log)
        except Exception as err:
            LOG.error('Failed to start AUT: %s', err)
            self.stop()
            raise err
        LOG.info('Launched AUT under PID: %d', self.pid)
        return self

    @allure.step('Close application')
    def stop(self):
        LOG.info('Stopping AUT: %s', self.path)
        self.detach_context()
        local_system.kill_process(self.pid)
        time.sleep(1) # FIXME: Implement waiting for process to actually exit.

    @allure.step("Start and attach AUT")
    def launch(self) -> 'AUT':
        self.startaut()
        self.wait()
        self.attach()
        return self

    @allure.step('Waiting for port')
    def wait(self, timeout: int = 1, retries: int = 10):
        LOG.info('Waiting for AUT port localhost:%d...', self.port)
        try:
            wait_for_port('localhost', self.port, timeout, retries)
        except TimeoutError as err:
            LOG.error('Wait for AUT port timed out: %s', err)
            self.stop()
            raise err
        LOG.info('AUT port available!')

    @allure.step('Restart application')
    def restart(self):
        self.stop()
        self.launch()
