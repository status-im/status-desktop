import pytest

from driver.aut import AUT

pytest_plugins = [
    'tests.fixtures.aut',
    'tests.fixtures.path',
    'tests.fixtures.squish',
]


@pytest.fixture(scope='session', autouse=True)
def setup_session_scope(
        run_dir,
        server,
):
    yield


def pytest_exception_interact(node):
    AUT.stop()
