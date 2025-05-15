import typing

import allure

from driver.objects_access import walk_children
from gui.elements.object import QObject
from gui.objects_map import names


class ToastMessage(QObject):

    def __init__(self):
        super(ToastMessage, self).__init__(names.ephemeral_Notification_List)
        self._toast_message = QObject(names.ephemeralNotificationList_StatusToastMessage)

    @allure.step('Get toast messages')
    def get_toast_messages(self) -> typing.List[str]:
        messages = []
        try:
            for child in walk_children(self.object):
                if getattr(child, 'id', '') == 'title':
                    messages.append(str(child.text))
        except Exception as e:
            raise LookupError(f"Failed to get toast messages: {e}")

        if not messages:
            raise LookupError('Toast messages are not found')
        return messages
