"""
Chat helper functions for common chat operations.
"""
import time
import allure

from gui.components.community.enable_message_backup_popup import EnableMessageBackupPopup


@allure.step('Skip Enable Messages backup popup')
def skip_message_backup_popup_if_visible():
    """
    Skip the message backup popup if it's visible.
    This is a common operation that appears in multiple places throughout the codebase.
    """
    # Small delay to ensure popup has time to appear
    time.sleep(0.1)
    
    message_back_up_popup = EnableMessageBackupPopup()
    if message_back_up_popup.is_visible:
        message_back_up_popup.skip_button.click()
        # Small delay after clicking to ensure action is processed
        time.sleep(0.1)
