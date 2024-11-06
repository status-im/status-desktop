import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.objects_map import names


class DeletePopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._delete_button = Button(names.delete_StatusButton)

    @allure.step("Delete channel")
    def delete(self, attempts: int = 2):
        try:
            self._delete_button.click()
        except Exception as ex:
            if attempts:
                self.delete(attempts - 1)
            else:
                raise ex


class DeleteCategoryPopup(DeletePopup):

    def __init__(self):
        super().__init__()
        self.confirm_button = Button(names.confirm_StatusButton)


class DeletePermissionPopup(DeletePopup):

    def __init__(self):
        super().__init__()
        self.confirm_delete_button = Button(names.confirm_permission_delete_StatusButton)


class DeleteMessagePopup(DeletePopup):

    def __init__(self):
        super().__init__()
        self._delete_button = Button(names.confirm_delete_message_StatusButton)
