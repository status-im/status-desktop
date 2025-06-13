import time

import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names


class ConfirmationPopup(QObject):

    def __init__(self):
        super().__init__(names.confirmationDialog)
        self.confirmation_dialog = QObject(names.confirmationDialog)
        self.delete_button = Button(names.delete_StatusButton)

    @allure.step("Delete channel")
    def delete(self, attempts: int = 2):
        for _ in range(attempts):
            try:
                self.delete_button.click()
                time.sleep(0.2)
            except Exception:
                pass  # Retry if attempts remain
        raise Exception(f"Delete button was not clicked after {attempts} attempts")



class ConfirmationCategoryPopup(ConfirmationPopup):

    def __init__(self):
        super().__init__()
        self.confirm_button = Button(names.confirm_StatusButton)


class ConfirmationPermissionPopup(ConfirmationPopup):

    def __init__(self):
        super().__init__()
        self.confirm_delete_button = Button(names.confirm_permission_delete_StatusButton)


class ConfirmationMessagePopup(QObject):

    def __init__(self):
        super().__init__(names.confirmationDeleteMessagePopup)
        self.delete_button = Button(names.confirm_delete_message_StatusButton)
