import typing

import allure

import configs.timeouts
import driver
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.objects_map import names


class InviteContactsPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._member_item = QObject(names.o_StatusMemberListItem)
        self._next_button = Button(names.next_StatusButton)
        self._message_text_edit = TextEdit(names.communityProfilePopupInviteMessagePanel_MessageInput_TextEdit)
        self._invited_member_item = QObject(names.o_StatusMemberListItem_2)
        self._send_button = Button(names.send_1_invite_StatusButton)

    @property
    @allure.step('Get contacts')
    def contacts(self) -> typing.List[str]:
        return [str(getattr(user, 'title', '')) for user in driver.findAllObjects(self._member_item.real_name)]

    @property
    @allure.step('Invite contacts')
    def invited_contacts(self) -> typing.List[str]:
        return [str(getattr(user, 'title', '')) for user in driver.findAllObjects(self._invited_member_item.real_name)]

    def invite(self, contacts: typing.List[str], message: str):
        for contact in contacts:
            assert driver.waitFor(lambda: contact in self.contacts, configs.timeouts.UI_LOAD_TIMEOUT_MSEC), \
                f'Contact: {contact} not found in {self.contacts}'

        selected = []
        for member in driver.findAllObjects(self._member_item.real_name):
            if str(getattr(member, 'title', '')) in contacts:
                driver.mouseClick(member)
                selected.append(member.title)

        assert len(contacts) == len(selected), f'Selected contacts: {selected}, expected: {contacts}'

        self._next_button.click()
        self._message_text_edit.text = message

        for contact in contacts:
            assert driver.waitFor(lambda: contact in self.invited_contacts, configs.timeouts.UI_LOAD_TIMEOUT_MSEC), \
                f'Contact: {contact} not found in {self.invited_contacts}'

        self._send_button.click()
        self.wait_until_hidden()
