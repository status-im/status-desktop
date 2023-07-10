import pytest

pytest_plugins = [
    'tests.fixtures.path',
    'tests.fixtures.squish',
]


@pytest.fixture(scope='session', autouse=True)
def setup_session_scope(
        run_dir,
):
    yield


def pytest_exception_interact(node):
    """Handles test on fail."""
    pass
