import logging
import time

import allure
import squish

import configs
from driver.server import SquishServer

_logger = logging.getLogger(__name__)


@allure.step('Attaching to "{0}"')
def attach(aut_id: str, timeout_sec: int = configs.timeouts.PROCESS_TIMEOUT_SEC):
    started_at = time.monotonic()
    _logger.debug(f'Attaching to {aut_id}')
    while True:
        try:
            context = squish.attachToApplication(aut_id, SquishServer().host, SquishServer().port)
            _logger.info(f'AUT: {aut_id} attached')
            return context
        except RuntimeError as err:
            time.sleep(1)
            assert time.monotonic() - started_at < timeout_sec, str(err)


@allure.step('Detaching')
def detach():
    for ctx in squish.applicationContextList():
        ctx.detach()
        assert squish.waitFor(lambda: not ctx.isRunning, configs.timeouts.APP_LOAD_TIMEOUT_MSEC)
    _logger.info(f'All AUTs detached')
