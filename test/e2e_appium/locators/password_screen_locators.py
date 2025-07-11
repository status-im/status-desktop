"""
Password Locators for Status Desktop E2E Testing

Element locators for password creation and confirmation screens.
"""

from appium.webdriver.common.appiumby import AppiumBy
from .base_locators import BaseLocators


class PasswordScreenLocators(BaseLocators):
    """Locators for the Password Creation Screen during onboarding"""
    
    # Screen identification - stable content-desc
    PASSWORD_SCREEN = (AppiumBy.ACCESSIBILITY_ID, "Create profile password")
    
    # Password input fields - using partial resource-ids to distinguish them
    # Both have content-desc="Type password" so we need to use resource-ids
    PASSWORD_INPUT = (AppiumBy.XPATH, "//*[contains(@resource-id, 'passwordViewNewPassword') and not(contains(@resource-id, 'Confirm'))]")
    PASSWORD_CONFIRM_INPUT = (AppiumBy.XPATH, "//*[contains(@resource-id, 'passwordViewNewPasswordConfirm')]")
    
    # Password creation button - stable content-desc
    CONFIRM_PASSWORD_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "Confirm password")
    # Fallback using resource-id
    CONFIRM_PASSWORD_BUTTON_BY_ID = (AppiumBy.XPATH, "//*[contains(@resource-id, 'btnConfirmPassword')]")
    
    # Container locator - stable without QMLTYPE
    ONBOARDING_CONTAINER = (AppiumBy.ID, "QGuiApplication.mainWindow.startupOnboardingLayout") 