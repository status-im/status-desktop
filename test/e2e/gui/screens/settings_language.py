import allure

from gui.components.onboarding.language_selector import LanguageSelector
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_label import TextLabel
from gui.objects_map import settings_names


class LanguageSettingsView(QObject):

    def __init__(self):
        super().__init__(settings_names.languageView)
        self.language_selector = TextLabel(settings_names.languageViewLanguageSelector)
        self._confirm_restart_button = Button(settings_names.languageViewLanguageChangeConfirmButton)

    @allure.step('Select language')
    def select_language(self, language_code: str):
        self.language_selector.click()
        LanguageSelector().wait_until_appears().select_language(language_code)

    @allure.step('Confirm language change and restart')
    def confirm_restart(self):
        self._confirm_restart_button.click()
