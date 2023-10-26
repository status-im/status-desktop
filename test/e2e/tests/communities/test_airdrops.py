import allure
import pytest
from allure_commons._allure import step

import constants
from constants.community_settings import AirdropsElements
from gui.main_window import MainWindow
from scripts.tools import image


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703200',
                 'Manage community: Manage Airdrops screen overview')
@pytest.mark.case(703200)
@pytest.mark.parametrize('params', [constants.community_params])
@pytest.mark.skip(reason='https://github.com/status-im/desktop-qa-automation/issues/186')
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
        with step('Airdrops welcome image is correct'):
            welcome_image = airdrops_screen.airdrops_welcome_image
            image.compare(welcome_image, 'airdrops_welcome_image.png')
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
