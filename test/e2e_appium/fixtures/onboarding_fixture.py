"""
Onboarding Flow Fixture for E2E Tests

This module provides reusable fixtures for onboarding functionality that can be
used across multiple test suites. It follows the Page Object Model pattern and
provides flexible configuration options.
"""

import random
import time
from dataclasses import dataclass, field
from datetime import datetime
from typing import Optional, Dict, Any

import pytest

from pages.onboarding import (
    WelcomePage,
    AnalyticsPage,
    CreateProfilePage,
    SeedPhraseInputPage,
    PasswordPage,
    SplashScreen,
    MainAppPage,
)
from utils.generators import generate_seed_phrase
from models.user_model import User, UserProfile
from config.logging_config import get_logger


@dataclass
class OnboardingConfig:
    """Configuration options for onboarding flow execution"""

    skip_analytics: bool = True
    skip_profile_creation: bool = False
    custom_user_data: Optional[Dict[str, Any]] = None
    timeout_per_step: int = 30
    take_screenshots: bool = False
    screenshot_path: Optional[str] = None
    validate_each_step: bool = True

    # Advanced options
    custom_password: Optional[str] = None
    custom_display_name: Optional[str] = None
    wait_for_complete_loading: bool = True
    verify_main_app: bool = True

    # Seed phrase import options
    use_seed_phrase: bool = False
    seed_phrase: Optional[str] = None

    # Test context
    test_environment: str = "e2e_test"
    test_metadata: Dict[str, Any] = field(default_factory=dict)


class OnboardingFlow:
    """
    Encapsulates the complete onboarding flow with reusable methods.

    This class provides a clean interface for executing onboarding steps
    and can be configured for different test scenarios.
    """

    def __init__(self, driver, config: OnboardingConfig = None, logger=None):
        self.driver = driver
        self.config = config or OnboardingConfig()
        self.logger = logger or get_logger("onboarding_flow")

        self.welcome_page = WelcomePage(self.driver)
        self.analytics_page = AnalyticsPage(self.driver)
        self.create_profile_page = CreateProfilePage(self.driver)
        self.seed_phrase_page = SeedPhraseInputPage(self.driver)
        self.password_page = PasswordPage(self.driver)
        self.loading_page = SplashScreen(self.driver)
        self.main_app_page = MainAppPage(self.driver)

        self.current_step = "initialization"
        self.start_time = datetime.now()
        self.step_results = {}

        self.test_user = self._create_test_user()

    def _create_test_user(self) -> User:
        """Create a test user with appropriate data for the environment"""

        if self.config.custom_user_data:
            return User.from_test_data(self.config.custom_user_data)

        display_name = (
            self.config.custom_display_name
            or f"E2E_User_{datetime.now().strftime('%H%M%S')}"
        )

        password = self.config.custom_password or "TestPassword123!"

        profile = UserProfile(
            display_name=display_name,
            bio=f"Created during E2E test at {datetime.now().isoformat()}",
        )

        return User(
            profile=profile,
            password=password,
            environment=self.config.test_environment,
            test_context=self.config.test_metadata,
        )

    def execute_complete_flow(self) -> Dict[str, Any]:
        """
        Execute the complete onboarding flow.

        Returns:
            Dict containing execution results and metadata
        """
        flow_type = (
            "seed phrase import"
            if self.config.use_seed_phrase
            else "new profile creation"
        )
        self.logger.info(
            f"🚀 Starting complete onboarding flow execution ({flow_type})"
        )

        try:
            self._execute_welcome_step()

            if not self.config.skip_analytics:
                self._execute_analytics_step()
            else:
                self._execute_analytics_skip_step()

            if self.config.use_seed_phrase:
                self._execute_seed_phrase_import_step()
            else:
                if not self.config.skip_profile_creation:
                    self._execute_create_profile_step()

            self._execute_password_step()
            self._execute_loading_step()

            if self.config.verify_main_app:
                self._execute_main_app_verification()

            execution_result = self._build_success_result()
            self.logger.info(
                f"✅ Complete onboarding flow executed successfully ({flow_type})"
            )
            return execution_result

        except Exception as e:
            error_result = self._build_error_result(e)
            self.logger.error(
                f"❌ Onboarding flow failed at step '{self.current_step}': {str(e)}"
            )
            raise OnboardingFlowError(
                f"Onboarding failed at step '{self.current_step}': {str(e)}",
                step=self.current_step,
                results=error_result,
            )

    def _execute_welcome_step(self):
        """Execute welcome screen interaction"""
        self.current_step = "welcome_screen"
        self.logger.info("Step 1: Welcome Screen")

        max_wait = 10
        for attempt in range(max_wait):
            try:
                elements = self.main_app_page.driver.find_elements("xpath", "//*")
                if len(elements) > 5:  # Basic UI structure loaded
                    break
                time.sleep(1)
            except Exception:
                time.sleep(1)

        try:
            self.main_app_page.driver.tap([(500, 300)])
            time.sleep(1)
        except Exception:
            pass  # Non-critical if tap fails

        if self.config.validate_each_step:
            assert self.welcome_page.is_screen_displayed(timeout=30), (
                "Welcome screen should be displayed"
            )

        self.welcome_page.click_create_profile()

        self.step_results["welcome_screen"] = {
            "success": True,
            "timestamp": datetime.now(),
        }

        if self.config.take_screenshots:
            self._take_screenshot("welcome_completed")

    def _execute_analytics_step(self):
        """Execute analytics screen interaction"""
        self.current_step = "analytics_screen"
        self.logger.info("Step 2: Analytics Screen (interacting)")

        if self.config.validate_each_step:
            assert self.analytics_page.is_screen_displayed(), (
                "Analytics screen should be displayed"
            )

        self.analytics_page.accept_analytics_sharing()

        self.step_results["analytics_screen"] = {
            "success": True,
            "action": "shared",
            "timestamp": datetime.now(),
        }

    def _execute_analytics_skip_step(self):
        """Execute analytics screen skip action"""
        self.current_step = "analytics_screen_skip"
        self.logger.info("Step 2: Analytics Screen (skipping)")

        if self.config.validate_each_step:
            assert self.analytics_page.is_screen_displayed(), (
                "Analytics screen should be displayed"
            )

        self.analytics_page.skip_analytics_sharing()

        self.step_results["analytics_screen"] = {
            "success": True,
            "action": "skipped",
            "timestamp": datetime.now(),
        }

        if self.config.take_screenshots:
            self._take_screenshot("analytics_skipped")

    def _execute_create_profile_step(self):
        """Execute create profile screen interaction"""
        self.current_step = "create_profile_screen"
        self.logger.info("Step 3: Create Profile Screen")

        if self.config.validate_each_step:
            assert self.create_profile_page.is_screen_displayed(), (
                "Create profile screen should be displayed"
            )

        self.create_profile_page.click_lets_go()

        self.step_results["create_profile_screen"] = {
            "success": True,
            "timestamp": datetime.now(),
        }

        if self.config.take_screenshots:
            self._take_screenshot("profile_created")

    def _execute_seed_phrase_import_step(self):
        """Execute seed phrase recovery flow step"""
        self.current_step = "seed_phrase_import"
        self.logger.info("Step 3: Seed Phrase Import")

        if self.config.validate_each_step:
            assert self.create_profile_page.is_screen_displayed(), (
                "Create profile screen should be displayed before seed import"
            )

        opened = self.create_profile_page.click_use_recovery_phrase()
        assert opened, "Should be able to open 'Use a recovery phrase' flow"

        if self.config.validate_each_step:
            assert self.seed_phrase_page.is_screen_displayed(), (
                "Seed phrase input screen should be displayed"
            )

        phrase = self.config.seed_phrase or generate_seed_phrase()

        imported = self.seed_phrase_page.import_seed_phrase(phrase)
        assert imported, "Seed phrase import should complete"
        try:
            # type: ignore[attr-defined]
            self.test_user.seed_phrase = phrase  # optional detail
        except Exception:
            pass

        self.step_results["seed_phrase_import"] = {
            "success": True,
            "word_count": len(phrase.split()),
            "timestamp": datetime.now(),
        }

        if self.config.take_screenshots:
            self._take_screenshot("seed_phrase_import_completed")

    def _execute_password_step(self):
        """Execute password creation step"""
        self.current_step = "password_screen"
        self.logger.info("Step 4: Password Screen")

        if self.config.validate_each_step:
            assert self.password_page.is_screen_displayed(), (
                "Password screen should be displayed"
            )

        success = self.password_page.create_password(self.test_user.password)
        assert success, "Should successfully create password"

        self.step_results["password_screen"] = {
            "success": True,
            "password_length": len(self.test_user.password),
            "timestamp": datetime.now(),
        }

        if self.config.take_screenshots:
            self._take_screenshot("password_created")

    def _execute_loading_step(self):
        """Execute loading screen wait"""
        self.current_step = "loading_screen"
        self.logger.info("Step 5: Loading Screen")

        if self.config.wait_for_complete_loading:
            success = self.loading_page.wait_for_loading_completion()
            assert success, "Should successfully complete loading"

        self.step_results["loading_screen"] = {
            "success": True,
            "timestamp": datetime.now(),
        }

    def _execute_main_app_verification(self):
        """Execute main app verification"""
        self.current_step = "main_app_verification"
        self.logger.info("Step 6: Main App Verification")

        assert self.main_app_page.is_main_app_loaded(), "Main app should be loaded"

        self.step_results["main_app_verification"] = {
            "success": True,
            "timestamp": datetime.now(),
        }

        if self.config.take_screenshots:
            self._take_screenshot("onboarding_completed")

    def _take_screenshot(self, name: str):
        """Take screenshot during flow execution"""
        if self.config.screenshot_path:
            try:
                timestamp = datetime.now().strftime("%H%M%S")
                screenshot_name = f"{name}_{timestamp}.png"
                screenshot_path = f"{self.config.screenshot_path}/{screenshot_name}"
                self.driver.save_screenshot(screenshot_path)
                self.logger.debug(f"📷 Screenshot saved: {screenshot_path}")
            except Exception as e:
                self.logger.warning(f"⚠️ Failed to take screenshot '{name}': {e}")

    def _build_success_result(self) -> Dict[str, Any]:
        """Build success result dictionary"""
        end_time = datetime.now()
        duration = (end_time - self.start_time).total_seconds()

        return {
            "success": True,
            "user_data": self.test_user.to_test_data(),
            "execution_time_seconds": duration,
            "steps_completed": list(self.step_results.keys()),
            "step_results": self.step_results,
            "config": self.config,
            "start_time": self.start_time.isoformat(),
            "end_time": end_time.isoformat(),
        }

    def _build_error_result(self, error: Exception) -> Dict[str, Any]:
        """Build error result dictionary"""
        end_time = datetime.now()
        duration = (end_time - self.start_time).total_seconds()

        return {
            "success": False,
            "error": str(error),
            "failed_step": self.current_step,
            "execution_time_seconds": duration,
            "steps_completed": list(self.step_results.keys()),
            "step_results": self.step_results,
            "config": self.config,
            "start_time": self.start_time.isoformat(),
            "end_time": end_time.isoformat(),
        }


class OnboardingFlowError(Exception):
    """Custom exception for onboarding flow failures"""

    def __init__(self, message: str, step: str = None, results: Dict[str, Any] = None):
        super().__init__(message)
        self.step = step
        self.results = results


# Pytest Fixtures


@pytest.fixture(scope="function")
def onboarding_config():
    """Default onboarding configuration fixture"""
    return OnboardingConfig()





@pytest.fixture(scope="function")
def onboarded_user(request, test_environment):
    """
    Execute the complete onboarding flow and return a result dictionary.

    Returns:
        dict: {
            'success': bool,
            'user_data': dict,                # includes display_name, ids, etc.
            'steps_completed': List[str],
            'step_results': Dict[str, Any],   # per-step info (e.g., analytics action)
            'execution_time_seconds': float,
            ...
        }

    Default behavior:
        - skip_analytics=True unless overridden with @pytest.mark.onboarding_config
        - validate_each_step=True, screenshots disabled by default

    Usage:
        def test_something_after_onboarding(onboarded_user):
            user_data = onboarded_user['user_data']
            assert user_data['display_name'] is not None
    """

    if hasattr(request.instance, "driver"):
        driver = request.instance.driver
        logger = getattr(request.instance, "logger", get_logger("onboarding_fixture"))
    else:
        from core import SessionManager

        session_manager = SessionManager(test_environment)
        driver = session_manager.get_driver()
        logger = get_logger("onboarding_fixture")

    config = OnboardingConfig()
    for marker in request.node.iter_markers():
        if marker.name == "onboarding_config":
            config = OnboardingConfig(**marker.kwargs)
            break

    onboarding_flow = OnboardingFlow(driver, config, logger)

    try:
        result = onboarding_flow.execute_complete_flow()
        logger.info("✅ Onboarding fixture completed successfully")
        request.node.onboarding_result = result

        return result

    except Exception as e:
        logger.error(f"❌ Onboarding fixture failed: {e}")
        raise






# Additional fixtures for better integration with existing patterns





@pytest.fixture(scope="function")
def onboarded_app(request, test_environment):
    """
    Execute onboarding and return a MainAppPage ready for UI interactions.

    Returns:
        MainAppPage: initialized on the main app UI after onboarding. The page
        object exposes:
            - onboarding_result (dict): same structure as returned by onboarded_user
            - user_data (dict): convenience alias for onboarding_result['user_data']
            - create_profile_method (str): method used ("password" or "seed_phrase")

    Profile Creation Methods:
        - "password": Force password-based profile creation
        - "seed_phrase": Force seed phrase import
        - "random" or omitted: 50/50 random selection (default)

    Usage:
        @pytest.mark.onboarding_config(create_profile_method="seed_phrase")
        def test_feature(onboarded_app):
            app = onboarded_app
            assert app.is_main_app_loaded()
    """
    from core import SessionManager
    from pages.onboarding import MainAppPage

    if hasattr(request.instance, "driver"):
        driver = request.instance.driver
        logger = getattr(request.instance, "logger", get_logger("onboarded_app"))
    else:
        session_manager = SessionManager(test_environment)
        driver = session_manager.get_driver()
        logger = get_logger("onboarded_app")

    config_kwargs = {}
    for marker in request.node.iter_markers():
        if marker.name == "onboarding_config":
            config_kwargs = marker.kwargs
            break

    method = config_kwargs.get("create_profile_method", "random")

    if method == "random":
        use_seed_phrase = random.choice([True, False])
    elif method == "seed_phrase":
        use_seed_phrase = True
    elif method == "password":
        use_seed_phrase = False
    else:
        raise ValueError(
            f"Invalid create_profile_method: {method}. Use 'password', 'seed_phrase', or 'random'"
        )

    config_kwargs["use_seed_phrase"] = use_seed_phrase
    if use_seed_phrase and "seed_phrase" not in config_kwargs:
        config_kwargs["seed_phrase"] = generate_seed_phrase()

    config_kwargs.pop("create_profile_method", None)

    config = OnboardingConfig(**config_kwargs)

    onboarding_flow = OnboardingFlow(driver, config, logger)
    result = onboarding_flow.execute_complete_flow()

    if not result["success"]:
        raise OnboardingFlowError("Failed to prepare onboarded app", results=result)

    main_app = MainAppPage(driver)
    main_app.onboarding_result = result
    main_app.user_data = result["user_data"]
    main_app.create_profile_method = "seed_phrase" if use_seed_phrase else "password"

    return main_app



