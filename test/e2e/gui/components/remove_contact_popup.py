from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names


class RemoveContactPopup(QObject):

    def __init__(self):
        super().__init__(names.removeContactPopup)
        self.remove_contact_button = Button(names.remove_contact_StatusButton)

