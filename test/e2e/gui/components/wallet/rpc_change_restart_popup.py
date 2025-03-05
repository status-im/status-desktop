import allure

import configs
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.text_label import TextLabel
from gui.objects_map import names


class RPCChangeRestartPopup(BasePopup):

    def __init__(self):
        super(RPCChangeRestartPopup, self).__init__()
        self._save_restart_later_button = Button(names.save_and_restart_later_StatusFlatButton)
        self._save_restart_now_button = Button(names.save_and_restart_Status_StatusButton)
        self._restart_required_text = TextLabel(names.restart_required_StatusBaseText)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._save_restart_now_button.wait_until_appears(timeout_msec)
        return self

    @allure.step('Click Save and restart later button')
    def save_and_restart_later(self):
        self._save_restart_later_button.click()
        self._save_restart_later_button.wait_until_hidden()
        return self
