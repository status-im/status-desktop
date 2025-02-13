from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names


class SignSendModalPopup(BasePopup):
    def __init__(self):
        super().__init__()
        self.sign_send_modal_title= QObject(names.signSendModalTitle)
        self.sign_send_modal_asset_item = QObject(names.signSendModalAssetBox)
        self.sign_send_modal_collectible_item = QObject(names.signSendModalCollectibleBox)
        self.sign_send_modal_recipient_item = QObject(names.signSendModalRecipientBox)
        self.sign_send_modal_network_item = QObject(names.signSendModalNetworkBox)
        self.sign_send_modal_fees_item = QObject(names.signSendModalFeesBox)
        self.sign_send_modal_sender_item = QObject(names.signSendModalSenderBox)
        self.sign_send_modal_sign_button = Button(names.signSendModalSignButton)
        self.sign_send_modal_reject_button = Button(names.signSendModalRejectButton)
