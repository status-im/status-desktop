import time
from collections import namedtuple

import allure

import driver.mouse
from gui.components.base_popup import BasePopup
from gui.elements.qt.button import Button
from gui.elements.qt.object import QObject
from gui.elements.qt.slider import Slider

shift_image = namedtuple('Shift', ['left', 'right', 'top', 'bottom'])


class ProfilePicturePopup(BasePopup):

    def __init__(self):
        super(ProfilePicturePopup, self).__init__()
        self._zoom_slider = Slider('o_StatusSlider')
        self._view = QObject('cropSpaceItem_Item')
        self._make_profile_picture_button = Button('make_this_my_profile_picture_StatusButton')
        self._slider_handler = QObject('o_DropShadow')

    @allure.step('Make profile image')
    def make_profile_picture(
            self,
            zoom: int = None,
            shift: shift_image = None
    ):
        if zoom is not None:
            self._zoom_slider.value = zoom
            # The slider changed value, but image updates only after click on slider
            self._slider_handler.click()
            time.sleep(1)
        if shift is not None:
            if shift.left:
                driver.mouse.press_and_move(self._view.object, 1, 1, shift.left, 1)
                time.sleep(1)
            if shift.right:
                driver.mouse.press_and_move(
                    self._view.object, self._view.width, 1, self._view.width - shift.right, 1)
                time.sleep(1)
            if shift.top:
                driver.mouse.press_and_move(self._view.object, 1, 1, 1, shift.top, step=1)
                time.sleep(1)
            if shift.bottom:
                driver.mouse.press_and_move(
                    self._view.object, 1, self._view.height, 1, self._view.height - shift.bottom, step=1)
                time.sleep(1)

            self._make_profile_picture_button.click()
            self.wait_until_hidden()
