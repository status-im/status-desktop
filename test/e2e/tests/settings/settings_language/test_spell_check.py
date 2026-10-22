import pytest
from allure_commons._allure import step

from constants import RandomCommunity
from constants.messaging import (
    SPELL_CHECK_CORRECTED_MESSAGE,
    SPELL_CHECK_MESSAGE_WITH_TYPO,
    SPELL_CHECK_MISSPELLED_WORD,
    SPELL_CHECK_SUGGESTION,
)
from driver.aut import AUT
from gui.main_window import MainWindow
from gui.screens.messages import MessagesScreen


def _open_group_chat_in_general_channel(main_screen: MainWindow, community_name: str):
    community_screen = main_screen.left_panel.open_community(community_name)
    community_screen.left_panel.select_channel('general')
    return MessagesScreen().group_chat.wait_until_appears()


def _type_misspelled_word(group_chat):
    group_chat.type_message(f'{SPELL_CHECK_MISSPELLED_WORD} ')


@pytest.mark.timeout(600)
@pytest.mark.settings_language
@pytest.mark.settings_all
def test_spell_check(aut: AUT, main_screen: MainWindow, user_account):
    community = RandomCommunity()
    with step('Create community and open general channel'):
        community_screen = main_screen.left_panel.create_community(community_data=community)
        community_screen.left_panel.select_channel('general')
        messages_screen = MessagesScreen()
        group_chat = messages_screen.group_chat.wait_until_appears()

    with step('Replace the typo from the message input context menu and send'):
        group_chat.apply_spelling_suggestion(
            SPELL_CHECK_MESSAGE_WITH_TYPO,
            SPELL_CHECK_MISSPELLED_WORD,
            SPELL_CHECK_SUGGESTION,
        )
        group_chat.confirm_sending_message()
        messages_screen.chat.find_message_by_text(SPELL_CHECK_CORRECTED_MESSAGE, 0)

    with step('Turn spell check off in language settings'):
        language_settings = main_screen.left_panel.open_settings().left_panel.open_language_settings()
        language_settings.set_spell_check(False)

    with step('Spell check stays off in the message input'):
        group_chat = _open_group_chat_in_general_channel(main_screen, community.name)
        _type_misspelled_word(group_chat)
        group_chat.wait_for_no_spell_issues()

    with step('Spell check stays off after restart'):
        aut.restart()
        main_screen.prepare()
        main_screen.authorize_user(user_account)
        group_chat = _open_group_chat_in_general_channel(main_screen, community.name)
        _type_misspelled_word(group_chat)
        group_chat.wait_for_no_spell_issues()

    with step('Send a message while spell check is off'):
        group_chat.confirm_sending_message()
        MessagesScreen().chat.find_message_by_text(SPELL_CHECK_MISSPELLED_WORD, 0)
