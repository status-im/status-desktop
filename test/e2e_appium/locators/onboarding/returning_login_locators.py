from ..base_locators import BaseLocators


class ReturningLoginLocators(BaseLocators):

    # Returning Login ("Welcome back") user selector button
    LOGIN_USER_SELECTOR_FULL_ID = BaseLocators.xpath(
        "//*[@resource-id='QGuiApplication.mainWindow.startupOnboardingLayout.OnboardingFlow_QMLTYPE_165.LoginScreen_QMLTYPE_364.loginUserSelector.LoginUserSelectorDelegate_QMLTYPE_370']"
    )
    LOGIN_USER_SELECTOR = BaseLocators.xpath(
        "//*[contains(@resource-id, 'loginUserSelector') or contains(@resource-id, 'LoginUserSelector')]"
    )

    # Dropdown item to proceed with login
    LOGIN_DROPDOWN_ITEM = BaseLocators.xpath(
        "//*[contains(@resource-id, 'StatusDropdown.logInDelegate') or contains(@resource-id, 'logInDelegate')]"
    )

    CREATE_PROFILE_DROPDOWN_ITEM = BaseLocators.xpath(
        "//*[contains(@resource-id, 'StatusDropdown.createProfileDelegate') or contains(@resource-id, 'createProfileDelegate')]"
    )

    # Text fallback for the Create profile item
    CREATE_PROFILE_TEXT = BaseLocators.text_contains("Create profile")
