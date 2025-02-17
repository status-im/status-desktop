import logging

import allure
import squish

import configs
import driver
from driver.server import SquishServer

LOG = logging.getLogger(__name__)


@allure.step('Get application context of "{0}"')
def get_context(aut_id: str):
    LOG.info('Attaching to: %s', aut_id)
    try:
        context = driver.attachToApplication(aut_id, SquishServer().host, SquishServer().port)
        if context is not None:
            LOG.info('AUT %s context found', aut_id)
            return context
    except RuntimeError as error:
        LOG.error('AUT %s context has not been found', aut_id)
        raise RuntimeError(f'No application context was found, {error}')


@allure.step('Detaching')
def detach():
    for ctx in driver.applicationContextList():
        ctx.detach()
        if squish.waitFor(lambda: ctx.isRunning, configs.timeouts.APP_LOAD_TIMEOUT_MSEC):
            LOG.error('Context %s is still running after the timeout', ctx)
            raise TimeoutError(f'Context {ctx} is still running after {configs.timeouts.APP_LOAD_TIMEOUT_MSEC} ms')
    LOG.info('All AUTs detached')
