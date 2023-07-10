import logging

import pytest

import driver

_logger = logging.getLogger(__name__)


@pytest.mark.self
def test_import_squish():
    _logger.info(str(driver.__dict__))
    driver.snooze(1)


@pytest.mark.self
def test_squish_server(server):
    pass
