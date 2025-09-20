import allure

from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names


class IntroduceYourselfPopup(QObject):
    def __init__(self):
        super().__init__(names.introduceYourselfEditProfileButton)

        self.skip_button = Button(names.introduceYourselfSkipButton)
        self.edit_profile_button = Button(names.introduceYourselfEditProfileButton)

    @allure.step('Skip introduce yourself')
    def skip_intro(self):
        self.skip_button.click()
        self.wait_until_hidden()
        return self
