

import allure

from gui.components.base_popup import BasePopup
from gui.components.wallet.send_popup import SendPopup
from gui.elements.object import QObject
from gui.objects_map import names


class AssetContextMenuPopup(BasePopup):
    def __init__(self):
        super(AssetContextMenuPopup, self).__init__()
        self._send_item = QObject(names.send_StatusMenuItem)
        self._receive_item = QObject(names.receive_StatusMenuItem)

    @allure.step('Click send item')
    def click_send_item(self):
        self._send_item.click()
        return SendPopup().wait_until_appears()

    @allure.step('Click receive item')
    def click_receive_item(self):
        self._receive_item.click()
        return self
