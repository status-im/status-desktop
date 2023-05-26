import configs
import squish 
from .base_element import BaseElement
import toplevelwindow


class BaseWindow(BaseElement):

    def prepare(self) -> 'BaseWindow':
        self.maximize()
        self.on_top_level()
        return self

    def maximize(self):
        def _maximize() -> bool:
            try:
                toplevelwindow.ToplevelWindow(self.existent).maximize()
                return True
            except RuntimeError:
                return False

        return squish.waitFor(lambda: _maximize(), configs.squish.UI_LOAD_TIMEOUT_MSEC)

    def minimize(self):
        def _minimize() -> bool:
            try:
                toplevelwindow.ToplevelWindow(self.existent).minimize()
                return True
            except RuntimeError:
                return False
    
        return squish.waitFor(lambda: _minimize(), configs.squish.UI_LOAD_TIMEOUT_MSEC)

    def set_focus(self):
        def _set_focus() -> bool:
            try:
                toplevelwindow.ToplevelWindow(self.existent).setFocus()
                return True
            except RuntimeError:
                return False
    
        return squish.waitFor(lambda: _set_focus(), configs.squish.UI_LOAD_TIMEOUT_MSEC)

    def on_top_level(self):
        def _on_top() -> bool:
            try:
                toplevelwindow.ToplevelWindow(self.existent).setForeground()
                return True
            except RuntimeError:
                return False
    
        return squish.waitFor(lambda: _on_top(), configs.squish.UI_LOAD_TIMEOUT_MSEC)

    def close(self):
        squish.sendEvent("QCloseEvent", self.existent)
