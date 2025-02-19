import pytest
import logging

from driver.server import SquishServer

LOG = logging.getLogger(__name__)


@pytest.fixture(scope='session')
def start_squish_server():
    LOG.info('Starting Squish Server...')
    server = SquishServer()
    server.stop()
    try:
        server.start()
        server.wait()
        yield server
    except Exception as err:
        LOG.error('Failed to start Squish Server: %s', err)
        pytest.exit(err)
    finally:
        LOG.info('Stopping Squish Server...')
        server.stop()
