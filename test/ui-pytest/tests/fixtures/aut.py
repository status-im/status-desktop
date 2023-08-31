from datetime import datetime

import pytest

import configs
import constants
from constants import UserAccount
from driver.aut import AUT
from gui.main_window import MainWindow
from gui.screens.onboarding import LoginView
from scripts.utils import system_path


@pytest.fixture()
def aut() -> AUT:
    if not configs.APP_DIR.exists():
        pytest.exit(f"Application not found: {configs.APP_DIR}")
    _aut = AUT()
    yield _aut


@pytest.fixture
def user_data(request) -> system_path.SystemPath:
    user_data = configs.testpath.STATUS_DATA / f'app_{datetime.now():%H%M%S_%f}' / 'data'
    if hasattr(request, 'param'):
        fp = request.param
        if isinstance(fp, str):
            fp = configs.testpath.TEST_USER_DATA / fp / 'data'
        assert fp.is_dir()
        fp.copy_to(user_data)
    yield user_data


@pytest.fixture
def main_window(aut: AUT, user_data):
    aut.launch(f'-d={user_data.parent}')
    yield MainWindow().wait_until_appears().prepare()
    aut.detach().stop()


@pytest.fixture
def user_account(request) -> UserAccount:
    if hasattr(request, 'param'):
        user_account = request.param
        assert isinstance(user_account, UserAccount)
    else:
        user_account = constants.user.user_account_default
    yield user_account


@pytest.fixture
def main_screen(user_account: UserAccount, main_window: MainWindow) -> MainWindow:
    if LoginView().is_visible:
        yield main_window.log_in(user_account)
    else:
        yield main_window.sign_up(user_account)


@pytest.fixture
def community(main_screen, request) -> dict:
    community_params = request.param
    communities_portal = main_screen.left_panel.open_communities_portal()
    create_community_form = communities_portal.open_create_community_popup()
    create_community_form.create(community_params)
    return community_params
