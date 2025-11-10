from typing import Type

from ..environment import ConfigurationError, EnvironmentConfig
from .base import Provider, SessionMetadata
from .browserstack import BrowserStackProvider
from .local import LocalProvider

_PROVIDER_REGISTRY = {
    "local": LocalProvider,
    "browserstack": BrowserStackProvider,
}


def create_provider(env_config: EnvironmentConfig) -> Provider:
    provider_name = env_config.provider.name.lower()
    try:
        provider_cls: Type[Provider] = _PROVIDER_REGISTRY[provider_name]
    except KeyError as exc:
        raise ConfigurationError(
            f"Provider '{env_config.provider.name}' is not registered"
        ) from exc
    return provider_cls(env_config)


__all__ = ["Provider", "SessionMetadata", "create_provider"]
