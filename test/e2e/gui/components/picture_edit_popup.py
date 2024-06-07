import time
from collections import namedtuple

import allure

import driver.mouse
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.slider import Slider
from gui.objects_map import names

shift_image = namedtuple('Shift', ['left', 'right', 'top', 'bottom'])


class PictureEditPopup(BasePopup):

    def __init__(self):
        super(PictureEditPopup, self).__init__()
        self._zoom_slider = Slider(names.o_StatusSlider)
        self._view = QObject(names.cropSpaceItem_Item)
        self._make_picture_button = Button(names.make_picture_StatusButton)
        self._slider_handler = QObject(names.o_DropShadow)

    @allure.step('Set zoom shift for picture and make picture')
    def set_zoom_shift_for_picture(
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
        self.make_picture()

    @allure.step('Make picture')
    def make_picture(self, attempts: int = 2):
        self._make_picture_button.click()
        try:
            self._make_picture_button.wait_until_hidden()
        except AssertionError as err:
            if attempts:
                self.make_picture(attempts - 1)
            else:
                raise err
