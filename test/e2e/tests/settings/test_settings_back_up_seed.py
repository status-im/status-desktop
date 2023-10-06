import allure
import pytest
from allure_commons._allure import step

from gui.components.back_up_your_seed_phrase_banner import BackUpSeedPhraseBanner
from gui.main_window import MainWindow


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703001','Backup seed phrase')
@pytest.mark.case(703001)
def test_back_up_seed_phrase(main_screen: MainWindow):
    with step('Open back up seed phrase in settings'):
        settings = main_screen.left_panel.open_settings()
        back_up = settings.left_panel.open_back_up_seed_phrase()
        back_up.back_up_seed_phrase()
    with step('Verify back up seed phrase banner disappeared'):
        assert not BackUpSeedPhraseBanner().is_visible, 'Secure your seed phrase banner visible'
