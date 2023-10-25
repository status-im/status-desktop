import allure
import pytest

from driver.server import SquishServer


@pytest.fixture(scope='session')
def start_squish_server():
    squish_server = SquishServer()
    squish_server.stop()
    attempt = 3
    while True:
        try:
            squish_server.start()
            squish_server.set_cursor_animation()
            break
        except AssertionError as err:
            attempt -= 1
            if not attempt:
                pytest.exit(err)
    yield squish_server
    squish_server.stop()
    if squish_server.config.exists():
        allure.attach.file(str(squish_server.config), 'Squish server config')
        squish_server.config.unlink()
