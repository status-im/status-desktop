import allure
import pytest

from . import marks

import constants
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703630', 'Create community')
@pytest.mark.case(703630)
@pytest.mark.parametrize('params', [constants.community_params])
def test_switch_fleet(aut, user_account, main_screen: MainWindow, params, switch_to_status_staging):
    pass