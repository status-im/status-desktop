from drivers.SquishDriver import *

from .base_popup import BasePopup


class SavedAddressPopup(BasePopup):
    def __init__(self):
        super(SavedAddressPopup, self).__init__()
        self._name_text_edit = TextEdit('mainWallet_Saved_Addreses_Popup_Name_Input')
        self._save_add_address_button = Button('mainWallet_Saved_Addreses_Popup_Address_Add_Button')


class AddSavedAddressPopup(SavedAddressPopup):
    def __init__(self):
        super(AddSavedAddressPopup, self).__init__()
        self._address_text_edit = TextEdit('mainWallet_Saved_Addreses_Popup_Address_Input_Edit')

    def add_saved_address(self, name: str, address: str):
        self._name_text_edit.text = name
        self._address_text_edit.clear(verify=False)
        self._address_text_edit.type_text(address)
        self._save_add_address_button.click()
        self.wait_until_hidden()


class EditSavedAddressPopup(SavedAddressPopup):

    def __init__(self):
        super(EditSavedAddressPopup, self).__init__()
        self._address_text_label = TextLabel('mainWallet_Saved_Addreses_Popup_Address_Input_Edit')

    def edit_saved_address(self, name: str):
        self._name_text_edit.text = name
        self._save_add_address_button.click()
        self.wait_until_hidden()
