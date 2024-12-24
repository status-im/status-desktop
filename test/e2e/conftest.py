import logging
import configs
import os
import allure
import pytest
import shortuuid

from tests import test_data
from PIL import ImageGrab
from configs.system import get_platform
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
        start_squish_server
):
    LOG.info('Session startup...')
    yield


@pytest.fixture(autouse=True)
def setup_function_scope(
        caplog,
        generate_test_data,
        check_result,
        application_logs,
        launch_keycard_controller
):
    # FIXME: broken due to KeyError: <_pytest.stash.StashKey object at 0x7fd1ba6d78c0>
    # caplog.set_level(configs.LOG_LEVEL)
    yield


def pytest_runtest_setup(item):
    test_data.test_name = item.name

    test_data.error = []
    test_data.steps = []


@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    rep = outcome.get_result()
    setattr(item, 'rep_' + rep.when, rep)

    if rep.when == 'call':
        if rep.failed:
            test_data.error = rep.longreprtext
        elif rep.outcome == 'passed':
            if test_data.error:
                rep.outcome = 'failed'
                error_text = str()
                for line in test_data.error:
                    error_text += f"{line}; \n ---- soft assert ---- \n\n"
                rep.longrepr = error_text
    elif rep.failed:
        test_data.error = rep.longreprtext


def pytest_exception_interact(node):
    test_path, test_name, test_params = generate_test_info(node)
    node_dir: SystemPath = configs.testpath.RUN / test_path / test_name / test_params
    node_dir.mkdir(parents=True, exist_ok=True)
    screenshot = node_dir / f'screenshot_{shortuuid.ShortUUID().random(length=10)}.png'
    try:
        ImageGrab.grab(xdisplay=configs.system.DISPLAY if get_platform() == "Linux" else None).save(screenshot)
        allure.attach(
            name='Screenshot on fail',
            body=screenshot.read_bytes(),
            attachment_type=allure.attachment_type.PNG
        )
    except FileNotFoundError:
        print("Screenshot was not generated or saved")
