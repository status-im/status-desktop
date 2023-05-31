from drivers.SquishDriver import *

from .base_popup import BasePopup


class BackUpCommunityPrivateKeyPopup(BasePopup):
    def __init__(self):
        super(BackUpCommunityPrivateKeyPopup, self).__init__()
        self._copy_private_key_button = Button('copyCommunityPrivateKeyButton')
        self._community_private_key_text_edit = TextEdit('transferOwnerShipTextEdit')

    @property
    def private_key(self) -> str:
        return self._community_private_key_text_edit.text    

    def copy_community_private_key(self):
        self._copy_private_key_button.click()     
        
