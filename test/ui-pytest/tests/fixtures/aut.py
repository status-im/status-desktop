from datetime import datetime

import pytest

import configs
from driver.aut import AUT
from scripts.utils import system_path


@pytest.fixture()
def aut() -> AUT:
    if not configs.APP_DIR.exists():
        pytest.exit(f"Application not found: {AUT}")
    _aut = AUT()
    yield _aut


@pytest.fixture
def app_data() -> system_path.SystemPath:
    yield configs.testpath.STATUS_DATA / f'app_{datetime.now():%H%M%S_%f}'


@pytest.fixture
def user_data(request) -> system_path.SystemPath:
    user_data = configs.testpath.STATUS_DATA / f'app_{datetime.now():%H%M%S_%f}' / 'data'
    if hasattr(request, 'param'):
        system_path.SystemPath(request.param).copy_to(user_data)
    yield user_data


@pytest.fixture
def user_data_two(request, user_data) -> system_path.SystemPath:
    user_data = configs.testpath.STATUS_DATA / f'app_{datetime.now():%H%M%S_%f}' / 'data'
    if hasattr(request, 'param'):
        system_path.SystemPath(request.param).copy_to(user_data)
    yield user_data


@pytest.fixture
def main_window(aut: AUT, user_data: system_path.SystemPath):
    aut.launch(f'-d={user_data.parent}')
    yield
    aut.detach().stop()
