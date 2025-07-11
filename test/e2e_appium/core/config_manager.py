import yaml
import json
import os
from pathlib import Path
from typing import Dict, Any, List
from .environment import EnvironmentConfig, ConfigurationError


class ConfigurationManager:
    def __init__(self, config_dir: Path = None) -> None:
        self.config_dir = config_dir or Path(__file__).parent.parent / "config"
        self.environments_dir = self.config_dir / "environments"
        self.schemas_dir = self.config_dir / "schemas"

    def load_environment(self, environment: str) -> EnvironmentConfig:
        base_config = self._load_yaml(self.environments_dir / "base.yaml")

        env_file = self.environments_dir / f"{environment}.yaml"
        if not env_file.exists():
            raise ConfigurationError(f"Environment '{environment}' not found")

        env_config = self._load_yaml(env_file)
        merged_config = self._deep_merge(base_config, env_config)

        self._validate_schema(merged_config)
        config = self._create_config_object(merged_config)
        config.validate()

        return config

    def list_available_environments(self) -> List[str]:
        env_files = self.environments_dir.glob("*.yaml")
        return [f.stem for f in env_files if f.stem != "base"]

    def _load_yaml(self, file_path: Path) -> Dict[str, Any]:
        try:
            with open(file_path, "r") as f:
                return yaml.safe_load(f)
        except yaml.YAMLError as e:
            raise ConfigurationError(f"Invalid YAML in {file_path}: {e}")

    def _deep_merge(self, base: Dict, override: Dict) -> Dict:
        result = base.copy()

        for key, value in override.items():
            if key == "extends":
                continue

            if (
                key in result
                and isinstance(result[key], dict)
                and isinstance(value, dict)
            ):
                result[key] = self._deep_merge(result[key], value)
            else:
                result[key] = value

        return result

    def _validate_schema(self, config: Dict[str, Any]) -> None:
        schema_file = self.schemas_dir / "environment.json"
        if not schema_file.exists():
            return

        try:
            import jsonschema

            with open(schema_file, "r") as f:
                schema = json.load(f)
            jsonschema.validate(config, schema)
        except ImportError:
            pass
        except (jsonschema.ValidationError, jsonschema.SchemaError) as e:
            raise ConfigurationError(f"Configuration validation failed: {e}")

    def _create_config_object(self, config: Dict[str, Any]) -> EnvironmentConfig:
        return EnvironmentConfig(
            environment=config["metadata"]["environment"],
            device_name=config["device"]["name"],
            platform_name=config["device"]["platform_name"],
            platform_version=config["device"]["platform_version"],
            app_source=config["app"],
            appium_config=config["appium"],
            capabilities=config["capabilities"],
            timeouts=config["timeouts"],
            directories=config["directories"],
            logging_config=config["logging"],
            lambdatest_config=config.get("lambdatest", {}),
        )


class EnvironmentSwitcher:
    def __init__(self) -> None:
        self.config_manager = ConfigurationManager()

    def switch_to(self, environment: str) -> EnvironmentConfig:
        available = self.config_manager.list_available_environments()
        if environment not in available:
            raise ConfigurationError(
                f"Environment '{environment}' not found. "
                f"Available: {', '.join(available)}"
            )

        config = self.config_manager.load_environment(environment)
        os.environ["CURRENT_TEST_ENVIRONMENT"] = environment

        return config

    def auto_detect_environment(self) -> str:
        if os.getenv("LT_USERNAME") and os.getenv("LT_ACCESS_KEY"):
            return "lambdatest"

        try:
            import requests

            requests.get("http://localhost:4723/status", timeout=2)
            return "local"
        except Exception:
            pass

        return "local"
