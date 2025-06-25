import allure
import pytest
from allure_commons._allure import step

from gui.main_window import MainWindow
from . import marks

pytestmark = marks

@allure.testcase('Shell regular dock button navigation', 'Test navigation through all dock buttons and back to Shell')
@pytest.mark.case('shell')
def test_shell_dock_navigation_complete_cycle(main_screen: MainWindow):
    """Test clicking each dock button in sequence and returning to shell after each one"""
    
    dock_buttons = ["Wallet", "Messages", "Communities", "Settings", "Market"]
    
    if not main_screen.shell.is_visible:
        main_screen.left_panel.open_shell()
        main_screen.shell.wait_for_shell_ui_loaded()
        assert main_screen.shell.is_visible, "Shell screen should be accessible"
    
    for button_name in dock_buttons:
        with step(f'Navigate to {button_name} from shell dock'):
            screen = main_screen.shell.open_from_dock(button_name)
            assert screen.is_visible, f"{button_name} screen should be visible after clicking dock button"

        with step(f'Verify Shell accessibility from {button_name}'):
            main_screen.left_panel.open_shell()
            assert main_screen.shell.is_visible, "Shell screen should be accessible"