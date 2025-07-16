from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import wallet_names


class RemoveSavedAddressPopup(QObject):
    def __init__(self):
        super().__init__(wallet_names.removeSavedAddressPopup)
        self.remove_saved_address_button = Button(wallet_names.removeSavedAddressButton)
        self.cancel_button = Button(wallet_names.cancelRemovalButton)
