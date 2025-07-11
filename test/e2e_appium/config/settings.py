import os
import logging
from dataclasses import dataclass, field
from typing import Dict, Any


@dataclass
class TestConfig:
    lt_username: str = field(default_factory=lambda: os.getenv("LT_USERNAME", ""))
    lt_access_key: str = field(default_factory=lambda: os.getenv("LT_ACCESS_KEY", ""))

    device_name: str = field(
        default_factory=lambda: os.getenv("DEVICE_NAME", "Galaxy Tab S8")
    )
    platform_name: str = field(
        default_factory=lambda: os.getenv("PLATFORM_NAME", "android")
    )
    platform_version: str = field(
        default_factory=lambda: os.getenv("PLATFORM_VERSION", "14")
    )
    device_orientation: str = field(
        default_factory=lambda: os.getenv("DEVICE_ORIENTATION", "landscape")
    )

    default_timeout: int = field(
        default_factory=lambda: int(os.getenv("DEFAULT_TIMEOUT", "30"))
    )
    element_wait_timeout: int = field(
        default_factory=lambda: int(os.getenv("ELEMENT_WAIT_TIMEOUT", "30"))
    )
    element_click_timeout: int = field(
        default_factory=lambda: int(os.getenv("ELEMENT_CLICK_TIMEOUT", "10"))
    )
    element_find_timeout: int = field(
        default_factory=lambda: int(os.getenv("ELEMENT_FIND_TIMEOUT", "15"))
    )

    status_app_url: str = field(
        default_factory=lambda: os.getenv("STATUS_APP_URL", "lt://")
    )

    lt_hub_url: str = "https://mobile-hub.lambdatest.com/wd/hub"
    build_name: str = field(
        default_factory=lambda: os.getenv("BUILD_NAME", "E2E_Appium Tests")
    )
    test_name: str = field(
        default_factory=lambda: os.getenv("TEST_NAME", "Automated Test Run")
    )
    idle_timeout: int = 600

    log_level: str = field(default_factory=lambda: os.getenv("LOG_LEVEL", "INFO"))
    enable_screenshots: bool = field(
        default_factory=lambda: os.getenv("ENABLE_SCREENSHOTS", "true").lower()
        == "true"
    )
    enable_video_recording: bool = field(
        default_factory=lambda: os.getenv("ENABLE_VIDEO_RECORDING", "true").lower()
        == "true"
    )
    enable_network_logs: bool = True
    enable_device_logs: bool = True

    screenshots_dir: str = field(
        default_factory=lambda: os.getenv("SCREENSHOTS_DIR", "screenshots")
    )
    logs_dir: str = field(default_factory=lambda: os.getenv("LOGS_DIR", "logs"))
    reports_dir: str = field(
        default_factory=lambda: os.getenv("REPORTS_DIR", "reports")
    )

    enable_xml_report: bool = field(
        default_factory=lambda: os.getenv("ENABLE_XML_REPORT", "true").lower() == "true"
    )
    enable_html_report: bool = field(
        default_factory=lambda: os.getenv("ENABLE_HTML_REPORT", "true").lower()
        == "true"
    )
    enable_junit_report: bool = field(
        default_factory=lambda: os.getenv("ENABLE_JUNIT_REPORT", "true").lower()
        == "true"
    )

    enable_performance_analytics: bool = field(
        default_factory=lambda: os.getenv(
            "E2E_ENABLE_PERFORMANCE_ANALYTICS", "false"
        ).lower()
        in ("true", "1", "yes", "on")
    )
    performance_report_days: int = field(
        default_factory=lambda: int(os.getenv("E2E_PERFORMANCE_REPORT_DAYS", "7"))
    )

    build_number: str = field(default_factory=lambda: os.getenv("BUILD_NUMBER", ""))
    build_url: str = field(default_factory=lambda: os.getenv("BUILD_URL", ""))
    git_commit: str = field(default_factory=lambda: os.getenv("GIT_COMMIT", ""))
    git_branch: str = field(default_factory=lambda: os.getenv("GIT_BRANCH", ""))

    local_appium_server: str = field(
        default_factory=lambda: os.getenv(
            "LOCAL_APPIUM_SERVER", "http://localhost:4723"
        )
    )
    local_app_path: str = field(default_factory=lambda: os.getenv("LOCAL_APP_PATH", ""))

    def __post_init__(self):
        self._validate_required_fields()
        self._validate_timeouts()
        self._validate_urls()
        self._create_directories()

    def _validate_required_fields(self):
        errors = []
        warnings = []

        test_environment = os.getenv("TEST_ENVIRONMENT", "local")

        if test_environment in ["lambdatest", "lt"]:
            if not self.lt_username:
                errors.append(
                    "LT_USERNAME environment variable is required for LambdaTest execution"
                )

            if not self.lt_access_key:
                errors.append(
                    "LT_ACCESS_KEY environment variable is required for LambdaTest execution"
                )

            if not self.status_app_url or self.status_app_url == "lt://":
                errors.append("STATUS_APP_URL must be provided (LambdaTest app ID)")
        else:
            if not self.lt_username or not self.lt_access_key:
                warnings.append(
                    "LambdaTest credentials not set (OK for local development)"
                )

        if warnings:
            logger = logging.getLogger(__name__)
            for warning in warnings:
                logger.warning(f"⚠️ {warning}")

        if errors:
            error_msg = "Configuration validation failed:\n" + "\n".join(
                f"  • {error}" for error in errors
            )
            error_msg += "\n\nPlease set the required environment variables. See env_variables.example for guidance."
            raise ValueError(error_msg)

    def _validate_timeouts(self):
        timeouts = {
            "default_timeout": self.default_timeout,
            "element_wait_timeout": self.element_wait_timeout,
            "element_click_timeout": self.element_click_timeout,
            "element_find_timeout": self.element_find_timeout,
        }

        for name, value in timeouts.items():
            if value < 5:
                raise ValueError(f"{name} must be at least 5 seconds, got {value}")
            if value > 300:
                raise ValueError(f"{name} should not exceed 300 seconds, got {value}")

    def _validate_urls(self):
        if self.status_app_url and not (
            self.status_app_url.startswith("lt://")
            or self.status_app_url.startswith("http")
        ):
            raise ValueError(
                "STATUS_APP_URL must be a LambdaTest app ID (lt://) or valid URL"
            )

    def _create_directories(self):
        for directory in [self.screenshots_dir, self.logs_dir, self.reports_dir]:
            if directory:
                os.makedirs(directory, exist_ok=True)

    def get_lambdatest_capabilities(self) -> Dict[str, Any]:
        build_name = self.build_name
        if self.build_number:
            build_name += f" - Build {self.build_number}"

        test_name = self.test_name
        if self.git_branch:
            test_name += f" ({self.git_branch})"

        return {
            "lt:options": {
                "w3c": True,
                "platformName": self.platform_name,
                "deviceName": self.device_name,
                "appiumVersion": "2.1.3",
                "platformVersion": self.platform_version,
                "app": self.status_app_url,
                "devicelog": self.enable_device_logs,
                "visual": self.enable_screenshots,
                "video": self.enable_video_recording,
                "build": build_name,
                "name": test_name,
                "project": "Status E2E_Appium",
                "deviceOrientation": self.device_orientation,
                "idleTimeout": self.idle_timeout,
                "isRealMobile": False,
            },
            "appium:options": {"automationName": "UiAutomator2"},
        }

    def get_local_capabilities(self) -> Dict[str, Any]:
        if not self.local_app_path:
            raise ValueError("local_app_path is required for local testing")

        return {
            "platformName": self.platform_name,
            "deviceName": self.device_name,
            "platformVersion": self.platform_version,
            "app": self.local_app_path,
            "automationName": "UiAutomator2",
        }

    def get_build_info(self) -> Dict[str, str]:
        return {
            "build_name": self.build_name,
            "test_name": self.test_name,
            "build_number": self.build_number,
            "build_url": self.build_url,
            "git_commit": self.git_commit,
            "git_branch": self.git_branch,
        }

    def summary(self) -> Dict[str, Any]:
        return {
            "device": f"{self.device_name} ({self.platform_name} {self.platform_version})",
            "app_url": self.status_app_url,
            "lt_username": self.lt_username,
            "lt_access_key": "***" + self.lt_access_key[-4:]
            if self.lt_access_key
            else "NOT SET",
            "hub_url": self.lt_hub_url + " (using secure ClientConfig auth)",
            "timeouts": {
                "default": self.default_timeout,
                "element_wait": self.element_wait_timeout,
                "click": self.element_click_timeout,
                "find": self.element_find_timeout,
            },
            "build_info": self.get_build_info(),
            "logging": {
                "level": self.log_level,
                "screenshots": self.enable_screenshots,
                "video": self.enable_video_recording,
            },
            "performance_analytics": {
                "enabled": self.enable_performance_analytics,
                "report_days": self.performance_report_days,
            },
        }


_config_instance = None


def get_config() -> TestConfig:
    global _config_instance
    if _config_instance is None:
        _config_instance = TestConfig()
    return _config_instance


def reload_config() -> TestConfig:
    global _config_instance
    _config_instance = None
    return get_config()
