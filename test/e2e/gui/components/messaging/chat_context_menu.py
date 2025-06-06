from gui.elements.object import QObject
from gui.objects_map import communities_names


class ChatContextMenu(QObject):
    def __init__(self):
        super().__init__(communities_names.chatContextMenu)

        self.delete_channel_context_item = QObject(communities_names.delete_or_leave_Channel_StatusMenuItem)
        self.edit_channel_from_context = QObject(communities_names.edit_Channel_StatusMenuItem)