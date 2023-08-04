import logging

import allure

import driver
from gui.elements.qt.object import QObject

_logger = logging.getLogger(__name__)


class Window(QObject):

    def prepare(self) -> 'Window':
        self.maximize()
        self.on_top_level()
        return self

    @allure.step("Maximize {0}")
    def maximize(self):
        assert driver.toplevel_window.maximize(self.real_name), 'Maximize failed'
        _logger.info(f'Window {getattr(self.object, "title", "")} is maximized')

    @allure.step("Minimize {0}")
    def minimize(self):
        assert driver.toplevel_window.minimize(self.real_name), 'Minimize failed'
        _logger.info(f'Window {getattr(self.object, "title", "")} is minimized')

    @allure.step("Set focus on {0}")
    def set_focus(self):
        assert driver.toplevel_window.set_focus(self.real_name), 'Set focus failed'
        _logger.info(f'Window {getattr(self.object, "title", "")} in focus')

    @allure.step("Move {0} on top")
    def on_top_level(self):
        assert driver.toplevel_window.on_top_level(self.real_name), 'Set on top failed'
        _logger.info(f'Window {getattr(self.object, "title", "")} moved on top')

    @allure.step("Close {0}")
    def close(self):
        driver.toplevel_window.close(self.real_name)
