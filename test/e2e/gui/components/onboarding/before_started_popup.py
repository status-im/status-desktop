import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.check_box import CheckBox
from gui.elements.object import QObject
from gui.objects_map import names


class BeforeStartedPopUp(BasePopup):

    def __init__(self):
        super().__init__()
        self._acknowledge_checkbox = CheckBox(names.acknowledge_checkbox)
        self._terms_of_use_checkBox = CheckBox(names.termsOfUseCheckBox_StatusCheckBox)
        self._acknowledgeIndicator = QObject(names.acknowledgeIndicator)
        self._termsOfUseIndicator = QObject(names.termsOfUseIndicator)
        self._get_started_button = Button(names.getStartedStatusButton_StatusButton)
        self._terms_of_use_link = QObject(names.termsOfUseLink_StatusBaseText)
        self._privacy_policy_link = QObject(names.privacyPolicyLink_StatusBaseText)

    @property
    @allure.step('Get visible attribute')
    def is_visible(self) -> bool:
        return self._get_started_button.is_visible

    @allure.step('Allow all and get started')
    def get_started(self):
        self._acknowledgeIndicator.click()
        assert self._acknowledge_checkbox.checkState != 0, f"Acknowledge checkbox is not checked"
        self._termsOfUseIndicator.click()
        assert self._terms_of_use_checkBox.checkState != 0, f"ToU checkbox is not checked"
        assert self._terms_of_use_link.is_visible, f"Terms of use link is missing"
        assert self._privacy_policy_link.is_visible, f"Privacy Policy link is missing"
        # TODO https://github.com/status-im/status-desktop/issues/15345
        self._get_started_button.click()
        self.wait_until_hidden()
