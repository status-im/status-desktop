from dataclasses import dataclass, field
from typing import Dict, Any, Optional


@dataclass
class TestUser:
    display_name: str
    password: str = "StatusPassword123!"
    seed_phrase: Optional[str] = None
    source: str = "created"

    def to_dict(self) -> Dict[str, Any]:
        return {
            "display_name": self.display_name,
            "password": self.password,
            "seed_phrase": self.seed_phrase,
            "source": self.source,
        }


@dataclass
class TestAppState:
    is_home_loaded: bool = False
    current_screen: str = "unknown"
    requires_authentication: bool = False
    has_existing_profiles: bool = False


@dataclass
class TestConfiguration:
    environment: str = "lambdatest"
    profile_method: str = "password"
    display_name: str = "TestUser"
    validate_steps: bool = True
    take_screenshots: bool = False
    custom_config: Dict[str, Any] = field(default_factory=dict)
    device_override: Optional[Dict[str, Any]] = None

    @classmethod
    def from_pytest_marker(cls, request, marker_name: str) -> "TestConfiguration":
        config = cls()
        for marker in request.node.iter_markers():
            if marker.name == marker_name:
                for key, value in marker.kwargs.items():
                    if hasattr(config, key):
                        setattr(config, key, value)
                    else:
                        config.custom_config[key] = value
                break
        return config
