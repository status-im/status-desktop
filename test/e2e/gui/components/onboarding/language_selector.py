import allure

from gui.elements.object import QObject
from gui.objects_map import names, onboarding_names


class LanguageSelector(QObject):
    def __init__(self):
        super().__init__(onboarding_names.statusDropdown)

        self.language_item = QObject(onboarding_names.startupLanguageSelector_item)

    @allure.step('Select random language')
    def select_language(self, language_code):
        self.language_item.real_name['objectName'] = 'itemDelegate_' + language_code
        self.language_item.click()
        self.wait_until_hidden()
