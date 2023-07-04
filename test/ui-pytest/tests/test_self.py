import logging

import pytest

import driver

_logger = logging.getLogger(__name__)


@pytest.mark.self
def test_import_squish():
    _logger.info(str(driver.__dict__))
    driver.snooze(1)
