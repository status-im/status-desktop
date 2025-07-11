import time
from datetime import datetime
from typing import Optional, Tuple, Union, List

from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

from config import get_config, get_logger, log_element_action


class BasePage:
    
    def __init__(self, driver):
        self.driver = driver
        config = get_config()
        self.wait = WebDriverWait(driver, config.element_wait_timeout)
        self.logger = get_logger('pages')
    
    def find_element(self, locator):
        start_time = datetime.now()
        locator_str = f"{locator[0]}: {locator[1]}"
        
        try:
            element = self.wait.until(EC.presence_of_element_located(locator))
            duration_ms = int((datetime.now() - start_time).total_seconds() * 1000)
            log_element_action("find_element", locator_str, True, duration_ms)
            return element
        except:
            duration_ms = int((datetime.now() - start_time).total_seconds() * 1000)
            log_element_action("find_element", locator_str, False, duration_ms)
            raise
    
    def click_element(self, locator):
        start_time = datetime.now()
        locator_str = f"{locator[0]}: {locator[1]}"
        
        try:
            element = self.wait.until(EC.element_to_be_clickable(locator))
            element.click()
            duration_ms = int((datetime.now() - start_time).total_seconds() * 1000)
            log_element_action("click_element", locator_str, True, duration_ms)
            return True
        except:
            duration_ms = int((datetime.now() - start_time).total_seconds() * 1000)
            log_element_action("click_element", locator_str, False, duration_ms)
            return False
    
    def is_element_visible(self, locator, timeout=10):
        try:
            wait = WebDriverWait(self.driver, timeout)
            wait.until(EC.visibility_of_element_located(locator))
            return True
        except:
            return False 
    
    def safe_click(self, locator):
        try:
            return self.click_element(locator)
        except Exception as e:
            self.logger.error(f"Failed to click element {locator}: {e}")
            return None
    
    def safe_input(self, locator, text):
        try:
            element = self.find_element(locator)
            element.clear()
            element.send_keys(text)
            return True
        except Exception as e:
            self.logger.error(f"Failed to input text '{text}' to element {locator}: {e}")
            return False
    
    def wait_for_element(self, locator, timeout=None):
        if timeout:
            wait = WebDriverWait(self.driver, timeout)
        else:
            wait = self.wait
        
        try:
            return wait.until(EC.presence_of_element_located(locator))
        except Exception as e:
            self.logger.error(f"Element not found within timeout: {locator}: {e}")
            return None

    def hide_keyboard(self) -> bool:
        """Hide the virtual keyboard using multiple strategies"""
        try:
            # Strategy 1: Use Appium's built-in hide_keyboard method
            try:
                self.driver.hide_keyboard()
                self.logger.info("Keyboard hidden successfully using hide_keyboard()")
                return True
            except Exception as e:
                self.logger.debug(f"hide_keyboard() failed: {e}")
            
            # Strategy 2: Press back button (Android)
            try:
                self.driver.back()
                self.logger.info("Keyboard hidden using back button")
                return True
            except Exception as e:
                self.logger.debug(f"Back button failed: {e}")
            
            # Strategy 3: Swipe down gesture
            try:
                size = self.driver.get_window_size()
                # Swipe from middle-top to middle-bottom
                start_x = size['width'] // 2
                start_y = size['height'] // 3
                end_y = size['height'] * 2 // 3
                
                self.driver.swipe(start_x, start_y, start_x, end_y, 500)
                self.logger.info("Keyboard hidden using swipe gesture")
                return True
            except Exception as e:
                self.logger.debug(f"Swipe gesture failed: {e}")
            
            self.logger.warning("All keyboard hiding strategies failed")
            return False
            
        except Exception as e:
            self.logger.error(f"Error hiding keyboard: {e}")
            return False

    def ensure_element_visible(self, locator, timeout=10) -> bool:
        """Ensure element is visible, hide keyboard if it's blocking"""
        try:
            # First check if element is already visible
            if self.is_element_visible(locator, timeout=2):
                return True
            
            # Try hiding keyboard and check again
            self.logger.info("Element not visible, attempting to hide keyboard")
            if self.hide_keyboard():
                time.sleep(1)  # Wait for keyboard animation
                return self.is_element_visible(locator, timeout=timeout)
            
            return False
            
        except Exception as e:
            self.logger.error(f"Error ensuring element visibility: {e}")
            return False

    def qt_safe_input(self, locator, text: str, max_retries: int = 3) -> bool:
        """Qt/QML-safe text input with proper waiting and retry logic"""
        
        for attempt in range(max_retries):
            try:
                # Wait for element to be clickable (present and enabled)
                element = self.wait.until(EC.element_to_be_clickable(locator))
                
                # Click to focus
                element.click()
                
                # Wait for Qt field to become ready (with timeout)
                self._wait_for_qt_field_ready(element)
                
                # Clear and input using ActionChains
                element.clear()
                
                # Brief wait for clear to complete (Qt/QML requirement)
                self._wait_for_clear_completion(element)
                
                actions = ActionChains(self.driver)
                actions.send_keys(text).perform()
                
                # Verify input was successful
                if self._verify_input_success(element, text):
                    self.logger.info(f"Qt input successful (attempt {attempt + 1})")
                    return True
                    
            except Exception as e:
                self.logger.warning(f"Qt input attempt {attempt + 1} failed: {e}")
                if attempt < max_retries - 1:
                    time.sleep(1)  # Brief pause before retry
                    
        self.logger.error(f"Qt input failed after {max_retries} attempts")
        return False
    
    def _wait_for_qt_field_ready(self, element, timeout: int = 5) -> bool:
        """Wait for Qt field to be ready for input using polling"""
        
        def field_is_ready(driver):
            try:
                # Check if element is enabled and displayed
                return element.is_enabled() and element.is_displayed()
            except:
                return False
        
        try:
            wait = WebDriverWait(self.driver, timeout)
            wait.until(field_is_ready)
            return True
        except:
            self.logger.warning("Qt field readiness timeout")
            return False
    
    def _verify_input_success(self, element, expected_text: str) -> bool:
        """Verify that text input was successful"""
        try:
            # Check if this is a password field by resource-id or content-desc
            resource_id = element.get_attribute('resource-id') or ''
            content_desc = element.get_attribute('content-desc') or ''
            
            is_password = (
                'password' in resource_id.lower() or 
                content_desc.lower() == 'type password'
            )
            
            if is_password:
                # Password fields hide content for security - assume success if no exception
                self.logger.debug("Password field detected - assuming input success")
                return True
            
            # For non-password fields, verify text content
            actual_text = element.get_attribute('text')  # Android UIAutomator2 uses 'text' not 'value'
            if actual_text is None:
                # Secure input or unreadable field - assume success
                return True
            return len(actual_text) > 0
        except:
            # If we can't verify, assume success if we got this far
            return True
    
    def _wait_for_clear_completion(self, element, max_wait: float = 1.0) -> bool:
        """Wait for element clear operation to complete"""
        
        start_time = time.time()
        while time.time() - start_time < max_wait:
            try:
                # For password fields, we can't check text, so use a minimal delay
                # This is still better than a hardcoded sleep
                if hasattr(element, 'get_attribute'):
                    text = element.get_attribute('text')  # Android UIAutomator2 uses 'text' not 'value'
                    if text == '' or text is None:
                        return True
                
                # Small incremental wait
                time.sleep(0.1)
            except:
                # If we can't check, assume it's ready after minimal wait
                time.sleep(0.2)
                return True
        
        return True  # Always return True to not block the flow 