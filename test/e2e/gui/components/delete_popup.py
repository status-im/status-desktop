import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button


class DeletePopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._delete_button = Button('delete_StatusButton')

    @allure.step("Delete entity")
    def delete(self):
        self._delete_button.click()
        self.wait_until_hidden()


class DeleteCategoryPopup(DeletePopup):

    def __init__(self):
        super().__init__()
        self._delete_button = Button('confirm_StatusButton')
