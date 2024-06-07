import logging
import re

import pytest

import configs
from scripts.utils.system_path import SystemPath

LOG = logging.getLogger(__name__)


@pytest.fixture
def generate_test_data(request):
    test_path, test_name, test_params = generate_test_info(request.node)
    configs.testpath.TEST = configs.testpath.RUN / test_path / test_name
    node_dir = configs.testpath.TEST / test_params
    configs.testpath.TEST_ARTIFACTS = node_dir / 'artifacts'
    configs.testpath.TEST_VP = configs.testpath.VP / test_path / test_name
    LOG.debug('Artifacts directory: %s',
                  configs.testpath.TEST_ARTIFACTS.relative_to(configs.testpath.ROOT))
    LOG.debug('Verification points directory: %s',
                  configs.testpath.TEST_VP.relative_to(configs.testpath.ROOT))
    LOG.info('Start test: %s', test_name)


def generate_test_info(node):
    pure_path = SystemPath(node.location[0]).parts[1:]
    test_path = SystemPath(*pure_path).with_suffix('')
    test_name = node.originalname
    test_params = re.sub('[^a-zA-Z0-9\n\-_]', '', node.name.strip(test_name))
    return test_path, test_name, test_params


@pytest.fixture(scope='session')
def prepare_test_directory():
    keep_results = 5
    run_name_pattern = 'run_????????_??????'
    runs = list(sorted(configs.testpath.RESULTS.glob(run_name_pattern)))
    if len(runs) > keep_results:
        del_runs = runs[:len(runs) - keep_results]
        for run in del_runs:
            SystemPath(run).rmtree(ignore_errors=True)
            LOG.info(f"Remove old test run directory: {run.relative_to(configs.testpath.ROOT)}")
    configs.testpath.RUN.mkdir(parents=True, exist_ok=True)
    LOG.info(f"Created new test run directory: {configs.testpath.RUN.relative_to(configs.testpath.ROOT)}")
