import time
import socket
import logging

LOG = logging.getLogger(__name__)


def wait_for_port(host: str, port: int, timeout: int = 3, retries: int = 0):
    for i in range(retries + 1):
        try:
            LOG.debug('Checking TCP port: %s:%d', host, port)
            with socket.create_connection((host, port), timeout=timeout):
                if socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect_ex((host, port)) == 0:
                    return
        except OSError as err:
            LOG.debug('Connection error: %s', err)
            time.sleep(1)
            continue

    LOG.debug('Timed out waiting for TCP port: %s:%d', host, port)
    raise TimeoutError(
        'Unable to establish TCP connection with %s:%s.' % (host, port)
    )
