import os
from datetime import datetime
from appium import webdriver
from appium.options.common import AppiumOptions
from appium.webdriver.appium_connection import AppiumConnection
from selenium.webdriver.remote.client_config import ClientConfig

try:
    from config import get_logger, log_session_info
    from core import EnvironmentSwitcher, ConfigurationError
except ImportError:
    from config import get_logger, log_session_info
    from core import EnvironmentSwitcher, ConfigurationError


class SessionManager:
    """Manages Appium driver sessions and environment configuration"""

    def __init__(self, environment="lambdatest", device_override=None):
        self.environment = environment
        self.driver = None
        self.logger = get_logger("session")
        self._device_override = device_override or None

        # Load YAML-based configuration (simplified)
        try:
            switcher = EnvironmentSwitcher()
            self.env_config = switcher.switch_to(environment)

            self.logger.info(f"✅ Configuration loaded for {environment}")
            self.logger.info(
                f"   Device: {self.env_config.device_name} ({self.env_config.platform_name} {self.env_config.platform_version})"
            )
            self.logger.info(f"   App: {self.env_config.get_resolved_app_path()}")

            # Log timeout configuration
            timeouts = self.env_config.timeouts
            self.logger.info(
                f"   Timeouts: default={timeouts.get('default')}s, wait={timeouts.get('element_wait')}s"
            )

            # Apply device override if provided
            if self._device_override:
                self._apply_device_override(self._device_override)

        except ConfigurationError as e:
            self.logger.error(f"❌ Configuration error: {e}")
            self.logger.error("💡 Ensure YAML configuration files are properly set up")
            raise

    def _apply_device_override(self, override: dict) -> None:
        """Override device fields from a device entry (name, platform_name, platform_version, tags)."""
        try:
            name = override.get("name")
            platform_name = override.get("platform_name", self.env_config.platform_name)
            platform_version = override.get(
                "platform_version", self.env_config.platform_version
            )
            if name:
                self.env_config.device_name = name
            if platform_name:
                self.env_config.platform_name = platform_name
            if platform_version:
                self.env_config.platform_version = platform_version
            self.logger.info(
                f"🔧 Device override applied → {self.env_config.device_name} ({self.env_config.platform_name} {self.env_config.platform_version})"
            )
        except Exception as e:
            self.logger.warning(f"Failed to apply device override: {e}")

    def _get_lambdatest_naming(self) -> dict:
        """Generate LambdaTest build and test names from YAML config."""
        if not self.env_config or not self.env_config.lambdatest_config:
            # Use sensible defaults if config missing
            timestamp = datetime.now().strftime("%Y%m%d_%H%M")
            return {
                "build": f"Status E2E Tests - {timestamp}",
                "name": "Automated Test",
                "project": "Status E2E_Appium",
            }

        lt_config = self.env_config.lambdatest_config

        # Get templates with defaults
        build_template = lt_config.get(
            "build_name_template", "Status E2E Tests - ${BUILD_NUMBER:-${TIMESTAMP}}"
        )
        test_template = lt_config.get(
            "test_name_template", "${TEST_NAME:-Automated Test}"
        )
        project_name = lt_config.get("project", "Status E2E_Appium")

        # Add timestamp as fallback for build number
        timestamp = datetime.now().strftime("%Y%m%d_%H%M")
        os.environ.setdefault("TIMESTAMP", timestamp)

        # Resolve templates
        build_name = self.env_config._resolve_template(build_template)
        test_name = self.env_config._resolve_template(test_template)

        # Add branch info if available
        git_branch = os.getenv("GIT_BRANCH")
        if git_branch and git_branch not in test_name:
            test_name += f" ({git_branch})"

        return {"build": build_name, "name": test_name, "project": project_name}

    def get_driver(self):
        if self.driver:
            return self.driver

        if self.environment in ["lt", "lambdatest"]:
            self.driver = self._create_lambdatest_driver()
        elif self.environment == "local":
            self.driver = self._create_local_driver()
        else:
            raise ValueError(f"Unsupported environment: {self.environment}")

        return self.driver

    def _create_lambdatest_driver(self):
        options = AppiumOptions()

        if self.env_config:
            # Use new YAML-based configuration
            capabilities = self.env_config.get_device_capabilities()
            server_url = self.env_config.get_appium_server_url()

            if self.env_config.environment == "lambdatest":
                # Get LambdaTest naming configuration
                naming = self._get_lambdatest_naming()

                capabilities.setdefault("lt:options", {}).update(
                    {
                        "app": self.env_config.get_resolved_app_path(),
                        "build": naming["build"],
                        "name": naming["name"],
                        "project": naming["project"],
                    }
                )

            # Get LambdaTest credentials (still from environment variables)
            username = os.getenv("LT_USERNAME")
            access_key = os.getenv("LT_ACCESS_KEY")

        else:
            raise ConfigurationError("Environment configuration not available")

        options.load_capabilities(capabilities)

        client_config = ClientConfig(
            remote_server_addr=server_url, username=username, password=access_key
        )

        # Simple retry for transient hub failures
        last_error = None
        for attempt in range(2):  # 2 attempts total
            try:
                driver = webdriver.Remote(
                    command_executor=AppiumConnection(client_config=client_config),
                    options=options,
                )
                session_id = driver.session_id if driver else "unknown"
                log_session_info(session_id, "created", environment=self.environment)
                return driver
            except Exception as e:
                self.logger.warning(
                    f"LambdaTest session creation attempt {attempt + 1} failed: {e}"
                )
                last_error = e
        # Raise last error if retries exhausted
        raise last_error

    def _create_local_driver(self):
        options = AppiumOptions()

        if self.env_config:
            # Use new YAML-based configuration
            capabilities = self.env_config.get_device_capabilities()
            server_url = self.env_config.get_appium_server_url()
        else:
            raise ConfigurationError(
                "Environment configuration not available for local driver"
            )

        options.load_capabilities(capabilities)

        return webdriver.Remote(server_url, options=options)

    def cleanup_driver(self):
        if self.driver:
            session_id = (
                self.driver.session_id
                if hasattr(self.driver, "session_id")
                else "unknown"
            )
            log_session_info(session_id, "cleanup", environment=self.environment)
            self.driver.quit()
            self.driver = None

    def get_configuration_summary(self):
        if self.env_config:
            return {
                "environment": self.env_config.environment,
                "device": f"{self.env_config.device_name} ({self.env_config.platform_name} {self.env_config.platform_version})",
                "app_source": self.env_config.app_source["source_type"],
                "app_path": self.env_config.get_resolved_app_path(),
                "appium_server": self.env_config.get_appium_server_url(),
            }
        return {"environment": self.environment}
