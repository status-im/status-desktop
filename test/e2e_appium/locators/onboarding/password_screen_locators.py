from ..base_locators import BaseLocators


class PasswordScreenLocators(BaseLocators):

    # Screen identification - stable content-desc
    PASSWORD_SCREEN = BaseLocators.accessibility_id("Create profile password")

    # TODO: Replace fallbacks with accessibility_id/tid
    
    PASSWORD_INPUT = BaseLocators.xpath(
        "//*[contains(@resource-id, 'passwordViewNewPassword') and not(contains(@resource-id, 'Confirm'))]"
    )
    PASSWORD_CONFIRM_INPUT = BaseLocators.xpath(
        "//*[contains(@resource-id, 'passwordViewNewPasswordConfirm')]"
    )

    # Password creation button - stable content-desc
    CONFIRM_PASSWORD_BUTTON = BaseLocators.accessibility_id("Confirm password")
    # Fallback using resource-id
    CONFIRM_PASSWORD_BUTTON_BY_ID = BaseLocators.xpath(
        "//*[contains(@resource-id, 'btnConfirmPassword')]"
    )

    ONBOARDING_CONTAINER = BaseLocators.id(
        "QGuiApplication.mainWindow.startupOnboardingLayout"
    )
