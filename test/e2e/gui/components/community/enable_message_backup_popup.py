from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import communities_names


class EnableMessageBackupPopup(QObject):
    def __init__(self):
        super().__init__(communities_names.enableMessageBackupPopup)

        self.skip_button = Button(communities_names.enableMessageBackupPopupSkipButton)