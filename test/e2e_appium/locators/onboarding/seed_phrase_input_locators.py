"""
Seed Phrase Input Locators for Status Desktop E2E Testing

Defines element locators for the seed phrase import screen. Uses stable
accessibility IDs where possible, plus alt variants for device differences.
"""

from ..base_locators import BaseLocators


class SeedPhraseInputLocators(BaseLocators):
    """Locators for the Seed Phrase Input screen"""

    # Screen identification
    SEED_PHRASE_INPUT_SCREEN = BaseLocators.accessibility_id(
        "Create profile using a recovery phrase"
    )

    @staticmethod
    def get_tab_locators(word_count: int) -> list:
        base = str(word_count)
        return [BaseLocators.accessibility_id(f"{base} word(s)")]

    # Continue / Import actions (primary + alternative)
    CONTINUE_BUTTON = BaseLocators.accessibility_id("Continue")

    IMPORT_BUTTON = BaseLocators.accessibility_id("Import")
    IMPORT_BUTTON_ALT = BaseLocators.accessibility_id("Import seed phrase")

    # Validation messages
    INVALID_SEED_TEXT = BaseLocators.accessibility_id("Invalid seed phrase")
    INVALID_SEED_TEXT_ALT = BaseLocators.accessibility_id("Seed phrase is invalid")

    # Dynamic input fields – resolved via helper methods below
    @staticmethod
    def get_seed_word_input_field(position: int) -> tuple:
        """Locator targeting resource-id that contains enterSeedPhraseInputField{n}."""
        return BaseLocators.xpath(
            f"//*[contains(@resource-id, 'enterSeedPhraseInputField{position}')]"
        )
