import allure

import configs
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.objects_map import names


class SwitchWakuModePopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._i_understand_button = Button(names.iUnderstandStatusButton)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._i_understand_button.wait_until_appears(timeout_msec)
        return self

    @allure.step('Click i understand button')
    def confirm(self):
        # TODO https://github.com/status-im/status-app/issues/15345
        self._i_understand_button.click()
