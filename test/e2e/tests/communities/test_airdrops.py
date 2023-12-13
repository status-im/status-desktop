import allure
import pytest
from allure_commons._allure import step
from . import marks

import constants
from constants.community_settings import AirdropsElements
from constants.images_paths import AIRDROPS_WELCOME_IMAGE_PATH
from gui.main_window import MainWindow

pytestmark = marks

@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703200',
                 'Manage community: Manage Airdrops screen overview')
@pytest.mark.case(703200)
@pytest.mark.parametrize('params', [constants.community_params])
def test_airdrops_screen(main_screen: MainWindow, params):
    with step('Create community'):
        main_screen.create_community(params)

    with step('Open airdrops view from community settings'):
        community_screen = main_screen.left_panel.select_community(params['name'])
        community_setting = community_screen.left_panel.open_community_settings()
        airdrops_screen = community_setting.left_panel.open_airdrops()

    with step('Verify all elements on airdrops screen'):
        with step('New airdrop button is present'):
            assert airdrops_screen.is_airdrops_owner_token_button_visible is True
        with step('Airdrops welcome image source path is correct'):
            assert AIRDROPS_WELCOME_IMAGE_PATH == airdrops_screen.airdrops_welcome_image_path
        with step('Airdrops welcome title is correct'):
            assert airdrops_screen.airdrops_welcome_title == AirdropsElements.WELCOME_TITLE.value
        with step('Airdrops welcome subtitle is correct'):
            assert airdrops_screen.airdrops_welcome_subtitle == AirdropsElements.WELCOME_SUBTITLE.value
        with step('Airdrops welcome checklist is correct'):
            assert AirdropsElements.WELCOME_CHECKLIST_ELEMENT_1.value == airdrops_screen.airdrops_checklist[0]
            assert AirdropsElements.WELCOME_CHECKLIST_ELEMENT_2.value == airdrops_screen.airdrops_checklist[1]
            assert AirdropsElements.WELCOME_CHECKLIST_ELEMENT_3.value == airdrops_screen.airdrops_checklist[2]
        with step('Airdrops infobox title and text are correct and button Mint Owner Token is visible'):
            assert airdrops_screen.airdrops_infobox_title == AirdropsElements.INFOBOX_TITLE.value
            assert airdrops_screen.airdrops_infobox_text == AirdropsElements.INFOBOX_TEXT.value
            assert airdrops_screen.is_airdrops_owner_token_button_visible is True
