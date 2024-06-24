import allure

import configs
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.objects_map import names


class RemoveContactPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._remove_contact_button = Button(names.remove_contact_StatusButton)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._remove_contact_button.wait_until_appears(timeout_msec)
        return self

    @allure.step('Remove contact')
    def remove(self):
        self._remove_contact_button.click()
