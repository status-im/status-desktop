from ..base_locators import BaseLocators


class LoadingScreenLocators(BaseLocators):

    # Loading screen container
    SPLASH_SCREEN = BaseLocators.id(
        "QGuiApplication.mainWindow.startupOnboardingLayout.ProfileCreationFlow_QMLTYPE_206.splashScreenV2"
    )

    # (avoiding dynamic QMLTYPE)
    SPLASH_SCREEN_PARTIAL = BaseLocators.xpath(
        "//*[contains(@resource-id, 'splashScreenV2')]"
    )

    PROGRESS_BAR = BaseLocators.xpath(
        "//*[contains(@resource-id, 'StatusProgressBar')]"
    )

    ONBOARDING_CONTAINER = BaseLocators.id(
        "QGuiApplication.mainWindow.startupOnboardingLayout"
    )
