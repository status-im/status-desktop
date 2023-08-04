import logging
import time

import allure
import squish

import configs

_logger = logging.getLogger(__name__)


@allure.step('Attaching to "{0}"')
def attach(aut_name: str, timeout_sec: int = configs.timeouts.PROCESS_TIMEOUT_SEC):
    started_at = time.monotonic()
    while True:
        try:
            context = squish.attachToApplication(aut_name)
            _logger.info(f'AUT: {aut_name} attached')
            return context
        except RuntimeError as err:
            _logger.debug(err)
            time.sleep(1)
        assert time.monotonic() - started_at < timeout_sec, f'Attach error: {aut_name}'


@allure.step('Detaching')
def detach():
    for ctx in squish.applicationContextList():
        ctx.detach()
        assert squish.waitFor(lambda: not ctx.isRunning, configs.timeouts.APP_LOAD_TIMEOUT_MSEC)
    _logger.info(f'All AUTs detached')
