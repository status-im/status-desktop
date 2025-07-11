"""
Configuration module for Status Desktop E2E Appium tests.
"""

from .settings import get_config, TestConfig
from .logging_config import (
    setup_logging,
    get_logger,
    log_test_start,
    log_test_end,
    log_element_action,
    log_session_info,
)

__all__ = [
    "get_config",
    "TestConfig",
    "setup_logging",
    "get_logger",
    "log_test_start",
    "log_test_end",
    "log_element_action",
    "log_session_info",
]
