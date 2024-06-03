import allure

import configs
import driver
from driver.objects_access import walk_children
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.text_edit import TextEdit
from gui.objects_map import names


class RenameKeypairPopup(BasePopup):

    def __init__(self):
        super(RenameKeypairPopup, self).__init__()
        self._rename_text_edit = TextEdit(names.edit_TextEdit)
        self._save_changes_button = Button(names.save_changes_rename_StatusButton)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        driver.waitForObjectExists(self._save_changes_button.real_name, timeout_msec)
        return self

    @allure.step('Rename keypair')
    def rename_keypair(self, name):
        for child in walk_children(self.object):
            if getattr(child, 'id', '') == 'edit':
                text_edit = TextEdit(real_name=driver.objectMap.realName(child))
                text_edit.text = name
        self._save_changes_button.click()
        self.wait_until_hidden()
