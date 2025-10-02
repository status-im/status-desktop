"""Welcome Back screen locators."""

from ..base_locators import BaseLocators


class WelcomeBackScreenLocators(BaseLocators):
    """Locators for the Welcome Back screen (returning users)."""

    # TODO: Replace fallbacks with accessibility_id/tid
    
    # Screen identification
    LOGIN_SCREEN = BaseLocators.xpath(
        "//*[contains(@resource-id, 'LoginScreen_QMLTYPE')]"
    )
    ONBOARDING_LAYOUT = BaseLocators.id(
        "QGuiApplication.mainWindow.startupOnboardingLayout"
    )

    # User selection elements
    USER_SELECTOR = BaseLocators.xpath(
        "//*[contains(@resource-id, 'loginUserSelector')]"
    )
    USER_SELECTOR_DELEGATE = BaseLocators.xpath(
        "//*[contains(@resource-id, 'LoginUserSelectorDelegate_QMLTYPE')]"
    )

    # Password input elements
    PASSWORD_BOX = BaseLocators.xpath("//*[contains(@resource-id, 'passwordBox')]")
    PASSWORD_INPUT = BaseLocators.xpath(
        "//*[contains(@resource-id, 'loginPasswordInput')]"
    )
    PASSWORD_INPUT_BY_DESC = BaseLocators.content_desc_exact("Password")

    # Login action
    LOGIN_BUTTON = BaseLocators.xpath("//*[contains(@resource-id, 'loginButton')]")
    LOGIN_BUTTON_BY_DESC = BaseLocators.content_desc_exact("Log In")

    # Fallback locators for robustness
    LOGIN_BUTTON_FALLBACKS = [
        BaseLocators.xpath("//*[contains(@resource-id, 'loginButton')]"),
        BaseLocators.content_desc_exact("Log In"),
        BaseLocators.text_exact("Log In"),
    ]

    PASSWORD_INPUT_FALLBACKS = [
        BaseLocators.xpath("//*[contains(@resource-id, 'loginPasswordInput')]"),
        BaseLocators.content_desc_exact("Password"),
        BaseLocators.xpath(
            "//android.widget.EditText[contains(@content-desc, 'Password')]"
        ),
    ]
