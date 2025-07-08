import allure
import pytest
from allure_commons._allure import step

from gui.main_window import MainWindow
from . import marks

pytestmark = marks


@allure.testcase('Home regular dock button navigation', 'Test navigation through all dock buttons and back to home')
@pytest.mark.case('home_all')
def test_home_dock_navigation_complete_cycle(main_screen: MainWindow):
    """Test clicking each dock button in sequence and returning to home after each one"""

    dock_buttons = ["Wallet", "Messages", "Communities", "Settings", "Market"]

    if not main_screen.home.is_visible:
        main_screen.left_panel.open_home_screen()
        main_screen.home.wait_for_home_ui_loaded()
        assert main_screen.home.is_visible, "Home screen should be accessible"

    for button_name in dock_buttons:
        with step(f'Navigate to {button_name} from home dock'):
            screen = main_screen.home.open_from_dock(button_name)
            assert screen.is_visible, f"{button_name} screen should be visible after clicking dock button"

        with step(f'Verify Home accessibility from {button_name}'):
            main_screen.left_panel.open_home_screen()
            assert main_screen.home.is_visible, "Home screen should be accessible"
