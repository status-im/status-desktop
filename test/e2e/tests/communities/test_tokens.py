import allure
import pytest
from allure_commons._allure import step
from . import marks

import constants
from constants.community_settings import TokensElements
from constants.images_paths import TOKENS_WELCOME_IMAGE_PATH
from gui.main_window import MainWindow
from scripts.tools import image

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703199',
                 'Manage community: Manage Mint Tokens screen overview')
@pytest.mark.case(703199)
@pytest.mark.parametrize('params', [constants.community_params])
def test_tokens_screen(main_screen: MainWindow, params):
    with step('Create community'):
        main_screen.create_community(params)

    with step('Open tokens view from community settings'):
        community_screen = main_screen.left_panel.select_community(params['name'])
        community_setting = community_screen.left_panel.open_community_settings()
        tokens_screen = community_setting.left_panel.open_tokens()

    with step('Verify all elements on tokens screen'):
        with step('Mint token button is present'):
            assert tokens_screen.is_tokens_owner_token_button_visible is True
        with step('Tokens welcome image path is correct'):
            assert TOKENS_WELCOME_IMAGE_PATH == tokens_screen.tokens_welcome_image_path
        with step('Tokens welcome title is correct'):
            assert tokens_screen.tokens_welcome_title == TokensElements.WELCOME_TITLE.value
        with step('Tokens welcome subtitle is correct'):
            assert tokens_screen.tokens_welcome_subtitle == TokensElements.WELCOME_SUBTITLE.value
        with step('Tokens welcome checklist is correct'):
            assert TokensElements.WELCOME_CHECKLIST_ELEMENT_1.value == tokens_screen.tokens_checklist[0]
            assert TokensElements.WELCOME_CHECKLIST_ELEMENT_2.value == tokens_screen.tokens_checklist[1]
            assert TokensElements.WELCOME_CHECKLIST_ELEMENT_3.value == tokens_screen.tokens_checklist[2]
        with step('Tokens infobox title and text are correct and button Mint Owner Token is visible'):
            assert tokens_screen.tokens_infobox_title == TokensElements.INFOBOX_TITLE.value
            assert tokens_screen.tokens_infobox_text == TokensElements.INFOBOX_TEXT.value
            assert tokens_screen.is_tokens_owner_token_button_visible is True
