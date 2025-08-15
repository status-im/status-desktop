"""
Seed Phrase Input Locators for Status Desktop E2E Testing

Defines element locators for the seed phrase import screen. Uses stable
accessibility IDs where possible, plus alt variants for device differences.
"""

from appium.webdriver.common.appiumby import AppiumBy
from .base_locators import BaseLocators


class SeedPhraseInputLocators(BaseLocators):
    """Locators for the Seed Phrase Input screen"""

    # Screen identification
    SEED_PHRASE_INPUT_SCREEN = (AppiumBy.ACCESSIBILITY_ID, "Seed phrase")

    # Tabs by word count (primary + alternative text variants)
    TAB_12_WORDS_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "12 words")
    TAB_12_WORDS_BUTTON_ALT = (AppiumBy.ACCESSIBILITY_ID, "12-word")

    TAB_18_WORDS_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "18 words")
    TAB_18_WORDS_BUTTON_ALT = (AppiumBy.ACCESSIBILITY_ID, "18-word")

    TAB_24_WORDS_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "24 words")
    TAB_24_WORDS_BUTTON_ALT = (AppiumBy.ACCESSIBILITY_ID, "24-word")

    # Continue / Import actions (primary + alternative)
    CONTINUE_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "Continue")
    CONTINUE_BUTTON_ALT = (AppiumBy.ACCESSIBILITY_ID, "Continue import")

    IMPORT_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "Import")
    IMPORT_BUTTON_ALT = (AppiumBy.ACCESSIBILITY_ID, "Import seed phrase")

    # Validation messages
    INVALID_SEED_TEXT = (AppiumBy.ACCESSIBILITY_ID, "Invalid seed phrase")
    INVALID_SEED_TEXT_ALT = (AppiumBy.ACCESSIBILITY_ID, "Seed phrase is invalid")

    # Dynamic input fields – resolved via helper methods below
    @staticmethod
    def get_seed_word_input_field(position: int) -> tuple:
        """Return locator for the given seed word input position (1..24)."""
        return (AppiumBy.ACCESSIBILITY_ID, f"Word {position}")

    @staticmethod
    def get_seed_word_input_field_alt(position: int) -> tuple:
        """Alternative locator text for the given seed word input position."""
        return (AppiumBy.ACCESSIBILITY_ID, f"Seed word {position}")
