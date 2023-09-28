import logging

import allure
import pytest
from allure_commons._allure import step

_logger = logging.getLogger(__name__)
pytestmark = allure.suite("Self")


@pytest.mark.self
def test_start_aut(main_window):
    with step("Verify: 'main_window' fixture launched test app and prepared main window"):
        assert main_window.exists
