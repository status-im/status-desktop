import allure

import configs
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.objects_map import names


class FleetPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._fleet_option_template = Button(names.fleet_option_template)
        self._confirm_button = Button(names.confirm_change_fleet_statusButton)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._fleet_option_template.wait_until_appears(timeout_msec)
        return self

    @allure.step('Choose fleet')
    def choose_fleet(self, fleet_object_name: str):
        self._fleet_option_template.real_name['objectName'] = fleet_object_name
        self._fleet_option_template.click()
        return self

    @allure.step('Confirm')
    def confirm(self):
        self._confirm_button.click(timeout=None)
        self.wait_until_hidden()