import logging

import driver

_logger = logging.getLogger(__name__)


def test_start_aut(main_window):
    driver.context.detach()
