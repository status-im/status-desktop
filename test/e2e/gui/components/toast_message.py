import allure

import driver
from gui.elements.object import QObject


class ToastMessage(QObject):

    def __init__(self):
        super(ToastMessage, self).__init__('ephemeral_Notification_List')
        self._toast_message = QObject('ephemeralNotificationList_StatusToastMessage')

    @property
    @allure.step('Get toast messages')
    def get_toast_messages(self):
        messages = []
        for obj in driver.findAllObjects(self._toast_message.real_name):
            messages.append(str(obj.primaryText))
        if len(messages) == 0:
            raise LookupError(
                'Toast messages were not found')
        else:
            return messages
