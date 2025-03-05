import allure

import configs
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_label import TextLabel
from gui.objects_map import names


class BlockUserPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._block_user_button = Button(names.block_StatusButton)
        self._cancel_button = Button(names.cancel_StatusFlatButton)
        self._block_warning_box = QObject(names.blockWarningBox_StatusWarningBox)
        self._you_will_not_see_text = TextLabel(names.youWillNotSeeText_StatusBaseText)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._block_user_button.wait_until_appears(timeout_msec)
        return self

    @allure.step('Block user')
    def block(self):
        # TODO https://github.com/status-im/status-desktop/issues/15345
        self._block_user_button.click()

    @allure.step('Get warning text')
    def get_warning_text(self) -> str:
        return str(self._block_warning_box.object.text)

    @allure.step('Get you will not see text')
    def get_you_will_not_see_text(self) -> str:
        return str(self._you_will_not_see_text.text)
