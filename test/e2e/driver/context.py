import logging

import allure
import squish

import configs
from driver.server import SquishServer

LOG = logging.getLogger(__name__)


@allure.step('Get application context of "{0}"')
def get_context(aut_id: str):
    LOG.info('Attaching to: %s', aut_id)
    try:
        context = squish.attachToApplication(aut_id, SquishServer().host, SquishServer().port)
        if context is not None:
            LOG.info('AUT %s context found', aut_id)
            return context
    except RuntimeError as error:
        LOG.error('AUT %s context has not been found', aut_id)
        raise error


@allure.step('Detaching')
def detach():
    for ctx in squish.applicationContextList():
        ctx.detach()
        assert squish.waitFor(lambda: not ctx.isRunning, configs.timeouts.APP_LOAD_TIMEOUT_MSEC)
    LOG.info('All AUTs detached')
