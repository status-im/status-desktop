import allure

import configs
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_label import TextLabel
from gui.objects_map import names


class ShareProfilePopup(QObject):

    def __init__(self):
        super().__init__(names.shareProfileDialog)
        self._profile_qr_code = QObject(names.o_Image)
        self._profile_link_input = QObject(names.profileLinkInput_StatusBaseInput)
        self._emoji_hash = TextLabel(names.o_EmojiHash)
        self._copy_button = Button(names.o_copy_icon_CopyButton)
        self._close_button = Button(names.closeCrossPopupButton)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._profile_qr_code.wait_until_appears(timeout_msec)
        return self

    @allure.step('Get profile link')
    def get_profile_link(self) -> str:
        return str(self._profile_link_input.object.placeholderText)

    @allure.step('Get profile qr code visibility')
    def is_profile_qr_code_visibile(self) -> bool:
        return self._profile_qr_code.is_visible

    @allure.step('Get profile emoji hash')
    def get_emoji_hash(self):
        return self._emoji_hash.object.publicKey

    @allure.step('Close share profile popup')
    def close(self):
        self._close_button.click()
