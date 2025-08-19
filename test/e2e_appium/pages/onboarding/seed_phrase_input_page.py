"""
Seed Phrase Input Page for Status Desktop E2E Testing

Page object for the seed phrase input screen during onboarding.
Supports importing existing seed phrases for account recovery.
"""

import time
from typing import List, Union

from selenium.webdriver.common.keys import Keys

from ..base_page import BasePage
from locators.onboarding.seed_phrase_input_locators import SeedPhraseInputLocators


class SeedPhraseInputPage(BasePage):
    """Page object for the Seed Phrase Input Screen during onboarding"""

    def __init__(self, driver):
        super().__init__(driver)
        self.locators = SeedPhraseInputLocators()
        self.IDENTITY_LOCATOR = self.locators.SEED_PHRASE_INPUT_SCREEN

    def select_word_count_tab(self, word_count: int) -> bool:
        """
        Select the appropriate tab for seed phrase word count.

        Args:
            word_count: Number of words in seed phrase (12, 18, or 24)

        Returns:
            bool: True if tab was selected successfully
        """
        self.logger.info(f"Selecting {word_count}-word tab")

        # Map word count to locators
        tab_locators = {
            12: [
                self.locators.TAB_12_WORDS_BUTTON,
                self.locators.TAB_12_WORDS_BUTTON_ALT,
            ],
            18: [
                self.locators.TAB_18_WORDS_BUTTON,
                self.locators.TAB_18_WORDS_BUTTON_ALT,
            ],
            24: [
                self.locators.TAB_24_WORDS_BUTTON,
                self.locators.TAB_24_WORDS_BUTTON_ALT,
            ],
        }

        if word_count not in tab_locators:
            self.logger.error(
                f"Invalid word count: {word_count}. Must be 12, 18, or 24"
            )
            return False

        # Try primary locator first, then alternative
        for locator in tab_locators[word_count]:
            if self.safe_click(locator):
                self.logger.info(f"✅ Selected {word_count}-word tab")
                return True

        self.logger.error(f"❌ Failed to select {word_count}-word tab")
        return False

    def enter_seed_phrase_words(
        self, seed_phrase: Union[str, List[str]], use_autocomplete: bool = False
    ) -> bool:
        """
        Enter seed phrase words into individual input fields.

        Args:
            seed_phrase: Seed phrase as string (space-separated) or list of words
            use_autocomplete: Whether to use autocomplete functionality (enter partial words)

        Returns:
            bool: True if all words were entered successfully
        """
        # Convert string to list if necessary
        if isinstance(seed_phrase, str):
            words = seed_phrase.strip().split()
        else:
            words = seed_phrase

        word_count = len(words)
        self.logger.info(f"Entering {word_count}-word seed phrase")

        # Validate word count
        if word_count not in [12, 18, 24]:
            self.logger.error(
                f"Invalid seed phrase length: {word_count}. Must be 12, 18, or 24 words"
            )
            return False

        # Select appropriate tab
        if not self.select_word_count_tab(word_count):
            return False

        # Enter each word
        for index, word in enumerate(words, start=1):
            if not self._enter_single_word(index, word, use_autocomplete):
                self.logger.error(f"❌ Failed to enter word {index}: '{word}'")
                return False

        self.logger.info(f"✅ Successfully entered all {word_count} seed phrase words")
        return True

    def _enter_single_word(
        self, position: int, word: str, use_autocomplete: bool = False
    ) -> bool:
        """
        Enter a single word into the specified position.

        Args:
            position: Word position (1-24)
            word: The word to enter
            use_autocomplete: Whether to use autocomplete (enter partial word + Enter)

        Returns:
            bool: True if word was entered successfully
        """
        self.logger.debug(f"Entering word {position}: '{word}'")

        # Get locator for this word position
        primary_locator = self.locators.get_seed_word_input_field(position)
        alt_locator = self.locators.get_seed_word_input_field_alt(position)

        # Find the input field
        element = None
        for locator in [primary_locator, alt_locator]:
            element = self.find_element_safe(locator)
            if element:
                break

        if not element:
            self.logger.error(f"Could not find input field for word {position}")
            return False

        try:
            # Clear any existing text
            element.clear()
            # Wait for clear using base helper instead of fixed sleep
            self._wait_for_clear_completion(element)

            if use_autocomplete and len(word) > 4:
                # Enter partial word for autocomplete
                partial_word = word[:-1]
                element.send_keys(partial_word)
                # Brief wait for autocomplete suggestions to appear (UI response time)
                time.sleep(0.2)  # TODO: Replace with WebDriverWait for autocomplete suggestions

                # Press Enter to select autocomplete suggestion
                element.send_keys(Keys.RETURN)
                self.logger.debug(
                    f"Used autocomplete for word {position}: '{partial_word}' -> '{word}'"
                )
            else:
                # Enter complete word
                element.send_keys(word)
                self.logger.debug(f"Entered complete word {position}: '{word}'")

            return True

        except Exception as e:
            self.logger.error(f"Error entering word {position}: {e}")
            return False

    def click_continue(self) -> bool:
        self.logger.info("Clicking Continue button")

        # Try multiple locator patterns
        continue_locators = [
            self.locators.CONTINUE_BUTTON,
            self.locators.CONTINUE_BUTTON_ALT,
            self.locators.IMPORT_BUTTON,
            self.locators.IMPORT_BUTTON_ALT,
        ]

        for locator in continue_locators:
            if self.safe_click(locator):
                self.logger.info("✅ Continue button clicked successfully")
                return True

        self.logger.error("❌ Failed to click Continue button")
        return False

    def get_validation_error(self) -> str:
        """
        Get any validation error message displayed.

        Returns:
            str: Error message text, or empty string if no error
        """
        error_locators = [
            self.locators.INVALID_SEED_TEXT,
            self.locators.INVALID_SEED_TEXT_ALT,
        ]

        for locator in error_locators:
            element = self.find_element_safe(locator)
            if element and element.is_displayed():
                error_text = element.text
                self.logger.info(f"Validation error found: '{error_text}'")
                return error_text

        return ""

    def is_continue_button_enabled(self) -> bool:
        """
        Check if the Continue/Import button is enabled.

        Returns:
            bool: True if button is enabled and clickable
        """
        continue_locators = [
            self.locators.CONTINUE_BUTTON,
            self.locators.CONTINUE_BUTTON_ALT,
            self.locators.IMPORT_BUTTON,
            self.locators.IMPORT_BUTTON_ALT,
        ]

        for locator in continue_locators:
            element = self.find_element_safe(locator)
            if element and element.is_displayed():
                is_enabled = element.is_enabled()
                self.logger.debug(f"Continue button enabled: {is_enabled}")
                return is_enabled

        self.logger.warning("Continue button not found")
        return False

    def import_seed_phrase(
        self, seed_phrase: Union[str, List[str]], use_autocomplete: bool = False
    ) -> bool:
        """
        Complete seed phrase import flow.

        Args:
            seed_phrase: Seed phrase as string (space-separated) or list of words
            use_autocomplete: Whether to use autocomplete functionality

        Returns:
            bool: True if import was successful
        """
        self.logger.info("Starting seed phrase import process")

        # Enter seed phrase words
        if not self.enter_seed_phrase_words(seed_phrase, use_autocomplete):
            return False

        # Wait a moment for validation
        time.sleep(1)

        # Check for validation errors
        error_message = self.get_validation_error()
        if error_message:
            self.logger.error(f"Seed phrase validation failed: {error_message}")
            return False

        # Check if continue button is enabled
        if not self.is_continue_button_enabled():
            self.logger.error(
                "Continue button is not enabled - seed phrase may be invalid"
            )
            return False

        # Click continue to import
        if not self.click_continue():
            return False

        self.logger.info("✅ Seed phrase import completed successfully")
        return True
