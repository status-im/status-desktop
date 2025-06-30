from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names


class ConfirmationPopup(QObject):

    def __init__(self):
        super().__init__(names.confirmationDialog)
        self.confirmation_dialog = QObject(names.confirmationDialog)
        self.delete_button = Button(names.delete_StatusButton)



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
