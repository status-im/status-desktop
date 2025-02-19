from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.objects_map import communities_names


class LeaveCommunityConfirmationPopup(BasePopup):
    def __init__(self):
        super().__init__()
        self.leave_button = Button(communities_names.leaveCommunityContextMenuItem)

    def confirm_action(self):
        self.leave_button.click()

