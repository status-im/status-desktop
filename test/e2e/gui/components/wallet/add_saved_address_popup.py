import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.elements.text_label import TextLabel
from gui.objects_map import names


class AddEditSavedAddressPopup(QObject):
    def __init__(self):
        super().__init__(names.addEditSavedAddressPopup)
        self.name_text_edit = TextEdit(names.mainWallet_Saved_Addreses_Popup_Name_Input)
        self.save_add_address_button = Button(names.mainWallet_Saved_Addreses_Popup_Address_Add_Button)
        self.address_text_edit = TextEdit(names.mainWallet_Saved_Addreses_Popup_Address_Input_Edit)


    @allure.step('Add saved address')
    def add_saved_address(self, name: str, address: str):
        self.name_text_edit.text = name
        self.address_text_edit.clear(verify=False)
        self.address_text_edit.type_text(address)
        self.save_add_address_button.click()
        self.wait_until_hidden()

    @allure.step('Edit saved address')
    def edit_saved_address(self, new_name: str):
        self.name_text_edit.text = new_name
        self.save_add_address_button.click()
        self.wait_until_hidden()




