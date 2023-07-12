import logging

import pytest

import configs
import driver

_logger = logging.getLogger(__name__)


@pytest.mark.self
def test_start_aut(main_window):
    driver.context.detach()
