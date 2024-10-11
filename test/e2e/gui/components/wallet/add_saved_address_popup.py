import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.text_edit import TextEdit
from gui.elements.text_label import TextLabel
from gui.objects_map import names


class AddSavedAddressPopup(BasePopup):
    def __init__(self):
        super().__init__()
        self._name_text_edit = TextEdit(names.mainWallet_Saved_Addreses_Popup_Name_Input)
        self._save_add_address_button = Button(names.mainWallet_Saved_Addreses_Popup_Address_Add_Button)


class AddressPopup(AddSavedAddressPopup):
    def __init__(self):
        super().__init__()
        self._address_text_edit = TextEdit(names.mainWallet_Saved_Addreses_Popup_Address_Input_Edit)

    @allure.step('Add saved address')
    def add_saved_address(self, name: str, address: str):
        self._name_text_edit.text = name
        self._address_text_edit.clear(verify=False)
        self._address_text_edit.type_text(address)
        self._save_add_address_button.click()
        self.wait_until_hidden()


class EditSavedAddressPopup(AddSavedAddressPopup):

    def __init__(self):
        super().__init__()
        self._address_text_label = TextLabel(names.mainWallet_Saved_Addreses_Popup_Address_Input_Edit)

    @allure.step('Edit saved address')
    def edit_saved_address(self, new_name: str):
        self._name_text_edit.text = new_name
        self._save_add_address_button.click()
        self.wait_until_hidden()
