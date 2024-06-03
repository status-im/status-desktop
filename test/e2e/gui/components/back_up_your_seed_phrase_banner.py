import allure

from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names


class BackUpSeedPhraseBanner(QObject):
    def __init__(self):
        super(BackUpSeedPhraseBanner, self).__init__(names.mainWindow_secureYourSeedPhraseBanner_ModuleWarning)
        self._back_up_seedBanner = QObject(names.mainWindow_secureYourSeedPhraseBanner_ModuleWarning)
        self._back_up_seedButton = Button(names.mainWindow_secureYourSeedPhraseBanner_Button)

    @allure.step('Verify banner presence')
    def does_back_up_seed_banner_exist(self):
        return self._back_up_seedBanner.exists

    @allure.step('Verify back up now button on the banner')
    def is_back_up_now_button_present(self):
        return self._back_up_seedButton.is_visible

    @allure.step('Wait until banner is hidden')
    def wait_to_hide_the_banner(self):
        self._back_up_seedBanner.wait_until_hidden()
