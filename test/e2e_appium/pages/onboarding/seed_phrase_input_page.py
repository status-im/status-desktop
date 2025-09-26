import time
from typing import List, Union

from ..base_page import BasePage
from locators.onboarding.seed_phrase_input_locators import SeedPhraseInputLocators


class SeedPhraseInputPage(BasePage):

    def __init__(self, driver, flow_type: str = "create"):
        super().__init__(driver)
        self.locators = SeedPhraseInputLocators()

        if flow_type == "login":
            self.IDENTITY_LOCATOR = self.locators.SEED_PHRASE_INPUT_SCREEN_LOGIN
        else:
            self.IDENTITY_LOCATOR = self.locators.SEED_PHRASE_INPUT_SCREEN_CREATE

    def paste_seed_phrase_via_clipboard(self, seed_phrase: str) -> bool:
        """Paste the seed phrase via clipboard into the first input."""
        PASTE_CHIP_X_OFFSET = 20
        PASTE_CHIP_Y_OFFSET = -36
        LONG_PRESS_DURATION = 800

        try:
            self.driver.set_clipboard_text(seed_phrase)
            self.logger.debug("Seed phrase set to clipboard")

            first_field_locator = self.locators.get_seed_word_input_field(1)
            element = self.find_element_safe(first_field_locator)
            if not element:
                self.logger.error("First seed input field not found")
                return False

            if not self.ensure_element_visible(first_field_locator):
                self.logger.warning("First field not fully visible; continuing anyway")

            self.gestures.element_tap(element)
            self.logger.debug("Clicked first input field")

            if not self.long_press_element(element, LONG_PRESS_DURATION):
                self.logger.error("Failed to perform long-press on input field")
                return False

            if not self.tap_coordinate_relative(
                element, PASTE_CHIP_X_OFFSET, PASTE_CHIP_Y_OFFSET
            ):
                self.logger.error("Failed to tap paste chip")
                return False

            time.sleep(0.5)
            self.logger.info("✅ Seed phrase paste completed successfully")
            self.hide_keyboard()
            return True

        except Exception as e:
            self.logger.error(f"Clipboard paste failed: {e}")
            return False

    def click_continue(self) -> bool:
        self.logger.info("Clicking Continue button")

        continue_locators = [self.locators.CONTINUE_BUTTON]

        for locator in continue_locators:
            if self.safe_click(locator):
                self.logger.info("✅ Continue button clicked successfully")
                return True

        self.logger.error("❌ Failed to click Continue button")
        return False

    def is_continue_button_enabled(self) -> bool:
        element = self.find_element_safe(self.locators.CONTINUE_BUTTON)
        if element and element.is_displayed():
            is_enabled = element.is_enabled()
            self.logger.debug(f"Continue button enabled: {is_enabled}")
            return is_enabled

        self.logger.warning("Continue button not found")
        return False

    def import_seed_phrase(self, seed_phrase: Union[str, List[str]]) -> bool:
        """Complete seed phrase import flow."""
        self.logger.info("Starting seed phrase import process")

        if isinstance(seed_phrase, list):
            seed_phrase = " ".join(seed_phrase)

        if not self.paste_seed_phrase_via_clipboard(seed_phrase):
            return False

        try:
            if self.hide_keyboard():
                time.sleep(0.5)
        except Exception:
            pass

        return self.click_continue()
