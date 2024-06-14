import logging
from datetime import datetime

import os
import allure
import pytest
from PIL import ImageGrab

import configs
from configs.system import IS_LIN
from fixtures.path import generate_test_info
from scripts.utils.system_path import SystemPath

# Send logs to pytest.log as well
handler = logging.FileHandler(filename=configs.PYTEST_LOG)
logging.basicConfig(
    level=os.getenv('LOG_LEVEL', 'INFO'),
    format='[%(asctime)s] (%(filename)18s:%(lineno)-3s) [%(levelname)-7s] --- %(message)s',
    handlers=[handler],
)
LOG = logging.getLogger(__name__)

pytest_plugins = [
    'fixtures.aut',
    'fixtures.path',
    'fixtures.squish',
    'fixtures.testrail',
]


@pytest.fixture(scope='session', autouse=True)
def setup_session_scope(
        init_testrail_api,
        prepare_test_directory,
        start_squish_server,
):
    LOG.info('Session startup...')
    yield


@pytest.fixture(autouse=True)
def setup_function_scope(
        caplog,
        generate_test_data,
        check_result,
        application_logs
):
    # FIXME: broken due to KeyError: <_pytest.stash.StashKey object at 0x7fd1ba6d78c0>
    # caplog.set_level(configs.LOG_LEVEL)
    yield


@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    rep = outcome.get_result()
    setattr(item, 'rep_' + rep.when, rep)


def pytest_exception_interact(node):
    test_path, test_name, test_params = generate_test_info(node)
    node_dir: SystemPath = configs.testpath.RUN / test_path / test_name / test_params
    node_dir.mkdir(parents=True, exist_ok=True)
    screenshot = node_dir / f'screenshot_{datetime.today().strftime("%Y-%m-%d %H-%M-%S")}.png'
    ImageGrab.grab(xdisplay=configs.system.DISPLAY if IS_LIN else None).save(screenshot)
    allure.attach(
        name='Screenshot on fail',
        body=screenshot.read_bytes(),
        attachment_type=allure.attachment_type.PNG
    )
