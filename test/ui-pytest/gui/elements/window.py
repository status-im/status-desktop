import logging

import driver
from gui.elements.base_object import QObject

_logger = logging.getLogger(__name__)


class Window(QObject):

    def prepare(self) -> 'Window':
        self.maximize()
        self.on_top_level()
        return self

    def maximize(self):
        assert driver.toplevel_window.maximize(self.real_name), 'Maximize failed'
        _logger.info(f'Window {getattr(self.object, "title", "")} is maximized')

    def minimize(self):
        assert driver.toplevel_window.minimize(self.real_name), 'Minimize failed'
        _logger.info(f'Window {getattr(self.object, "title", "")} is minimized')

    def set_focus(self):
        assert driver.toplevel_window.set_focus(self.real_name), 'Set focus failed'
        _logger.info(f'Window {getattr(self.object, "title", "")} in focus')

    def on_top_level(self):
        assert driver.toplevel_window.on_top_level(self.real_name), 'Set on top failed'
        _logger.info(f'Window {getattr(self.object, "title", "")} moved on top')

    def close(self):
        driver.toplevel_window.close(self.real_name)

    def close_existed(self) -> bool:
        if self.exists:
            self.close()
            return True
        return False
