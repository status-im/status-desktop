import allure

from driver import objects_access
from gui.elements.object import QObject


class WalletToastMessage(QObject):

    def __init__(self):
        super(WalletToastMessage, self).__init__('ephemeralNotificationList_StatusToastMessage')
        self._wallet_toast_messages_list = QObject('mainWallet_Ephemeral_Notification_List')

    @allure.step('Check message at the bottom')
    def get_toast_message(self, name: str):
        for item in objects_access.walk_children(self._wallet_toast_messages_list.object):
            if getattr(item, 'text', '') == name:
                return item
        raise LookupError(f'Wallet toast message: {name} not found')
