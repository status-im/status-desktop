import allure
import pytest
from allure_commons._allure import step

import driver
from . import marks

import configs
from gui.components.back_up_your_seed_phrase_banner import BackUpSeedPhraseBanner
from gui.main_window import MainWindow

pytestmark = marks


@pytest.mark.critical
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703001', 'Backup seed phrase')
@pytest.mark.case(703001)
def test_back_up_seed_phrase(main_screen: MainWindow):
    with step('Check back up seed phrase option is visible for new account'):
        settings = main_screen.left_panel.open_settings()
        assert driver.waitFor(lambda: settings.left_panel.settings_section_back_up_seed_option.wait_until_appears,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f"Back up seed option is not present"
        if not configs.system.TEST_MODE and not configs._local.DEV_BUILD:
            assert BackUpSeedPhraseBanner().does_back_up_seed_banner_exist(), "Back up seed banner is not present"
            assert BackUpSeedPhraseBanner().is_back_up_now_button_present(), 'Back up now button is not present'

    with step('Open back up seed phrase in settings'):
        back_up = settings.left_panel.open_back_up_seed_phrase()
        back_up.back_up_seed_phrase()

    with step('Verify back up seed phrase banner disappeared'):
        assert not settings.left_panel.settings_section_back_up_seed_option.exists, f"Back up seed option is present"
        if not configs.system.TEST_MODE and not configs._local.DEV_BUILD:
            BackUpSeedPhraseBanner().wait_to_hide_the_banner()
            assert not BackUpSeedPhraseBanner().does_back_up_seed_banner_exist(), "Back up seed banner is present"
