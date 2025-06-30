from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names


class AcceptIgnoreRequestFromProfile(QObject):

    def __init__(self):
        super().__init__(names.reviewContactRequestPopup)
        self.accept_button = Button(names.accept_StatusButton)
        self.ignore_button = Button(names.ignore_StatusFlatButton)

