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
    
    dock_buttons = [
        ("Wallet", main_screen.shell.open_wallet_from_dock),
        ("Messages", main_screen.shell.open_messages_from_dock),
        ("Communities", main_screen.shell.open_communities_from_dock),
        ("Settings", main_screen.shell.open_settings_from_dock),
        ("Market", main_screen.shell.open_market_from_dock)
    ]
    
    if not main_screen.shell.is_visible:
        main_screen.left_panel.open_shell()
        main_screen.shell.wait_for_shell_ui_loaded()
        assert main_screen.shell.is_visible, "Shell screen should be accessible"
    
    for button_name, open_method in dock_buttons:
        with step(f'Navigate to {button_name} from shell dock'):
            screen = open_method()
            assert screen.is_visible, f"{button_name} screen should be visible after clicking dock button"

        with step(f'Verify Shell accessibility from {button_name}'):
            main_screen.left_panel.open_shell()
            assert main_screen.shell.is_visible, "Shell screen should be accessible"