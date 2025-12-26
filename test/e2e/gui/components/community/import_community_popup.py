import allure

from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.objects_map import communities_names
from gui.screens.community import CommunityScreen
from helpers.chat_helper import skip_message_backup_popup_if_visible


class ImportCommunityPopup(QObject):
    def __init__(self):
        super().__init__(communities_names.importCommunityPopup)

        self.community_key_input = TextEdit(communities_names.importCommunityPopup_KeyInput)
        self.join_button = Button(communities_names.importCommunityPopup_JoinButton)


    @allure.step('Import community with key')
    def import_community_with_key(self):
        self.community_key_input.type_text('https://status.app/c/G3kAAMSQtb05kog3aGbr3kiaxN4tF5xy4BAGEkkLwILk2z3GcoYlm5hSJXGn7J3laft-tnTwDWmYJ18dP_3bgX96dqr_8E3qKAvxDf3NrrCMUBp4R9EYkQez9XSM4486mXoC3mIln2zc-be7fG--Xq4Pqz5NNRY=#zQ3shZeEJqTC1xhGUjxuS4rtHSrhJ8vUYp64v6qWkLpvdy9L9')
        self.join_button.wait_until_appears(timeout_msec=30000)
        self.join_button.click()
        skip_message_backup_popup_if_visible()
        return CommunityScreen().wait_until_appears()

