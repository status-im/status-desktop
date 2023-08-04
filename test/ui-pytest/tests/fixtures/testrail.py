import logging
import typing

import pytest
from testrail_api import TestRailAPI

import configs

_logger = logging.getLogger(__name__)

testrail_api = None

PASS = 1
FAIL = 5
RETEST = 4


@pytest.fixture(scope='session')
def init_testrail_api(request):
    global testrail_api
    if configs.testrail.TESTRAIL_RUN_ID:
        _logger.info('TestRail API initializing')
        testrail_api = TestRailAPI(
            configs.testrail.TESTRAIL_URL,
            configs.testrail.TESTRAIL_USER,
            configs.testrail.TESTRAIL_PWD
        )
        test_case_ids = get_test_ids_in_session(request)
        for test_case_id in test_case_ids:
            if is_test_case_in_run(test_case_id):
                _update_result(test_case_id, RETEST)
                _logger.info(f'Test: "{test_case_id}" marked as "Retest"')
            else:
                _logger.info(f'Report result for test case: {test_case_id} skipped, not in test run')
    else:
        _logger.info('TestRail report skipped')


@pytest.fixture
def check_result(request):
    yield
    if configs.testrail.TESTRAIL_RUN_ID:
        item = request.node
        test_case_ids = _find_test_case_id_markers(request)
        for test_case_id in test_case_ids:
            if is_test_case_in_run(test_case_id):
                current_test_status = _get_test_case_status(test_case_id)
                if item.rep_call.failed:
                    if current_test_status != FAIL:
                        _update_result(test_case_id, FAIL)
                    _update_comment(test_case_id, f"{request.node.name} FAILED")
                else:
                    if current_test_status != FAIL:
                        _update_result(test_case_id, PASS)
                    _update_comment(test_case_id, f"{request.node.name} SUCCESS")


def _update_result(test_case_id: int, result: int):
    testrail_api.results.add_result_for_case(
        run_id=configs.testrail.TESTRAIL_RUN_ID,
        case_id=test_case_id,
        status_id=result,
    )


def _update_comment(test_case_id: int, comment: str):
    testrail_api.results.add_result_for_case(
        run_id=configs.testrail.TESTRAIL_RUN_ID,
        case_id=test_case_id,
        comment=comment
    )


def _find_test_case_id_markers(request) -> typing.List[int]:
    for marker in request.node.own_markers:
        if marker.name == 'case':
            test_case_ids = marker.args
            return test_case_ids
    return []


def _get_test_case_status(test_case_id: int) -> int:
    test_case_results = testrail_api.results.get_results_for_case(configs.testrail.TESTRAIL_RUN_ID, test_case_id)
    try:
        result = 0
        while True:
            last_test_case_status = test_case_results['results'][result]['status_id']
            if last_test_case_status is None:
                result += 1
            else:
                return last_test_case_status
    except:
        return RETEST


def is_test_case_in_run(test_case_id: int) -> bool:
    try:
        testrail_api.results.get_results_for_case(configs.testrail.TESTRAIL_RUN_ID, test_case_id)
    except Exception as err:
        return False
    else:
        return True


def _get_test_cases():
    results = []
    limit = 250
    chunk = 0
    while True:
        tests = testrail_api.tests.get_tests(configs.testrail.TESTRAIL_RUN_ID, offset=chunk)['tests']
        results.extend(tests)
        if len(tests) == limit:
            chunk += limit
        else:
            return results


def get_test_ids_in_session(request):
    tests = request.session.items
    ids = []
    for test in tests:
        for marker in getattr(test, 'own_markers', []):
            if getattr(marker, 'name', '') == 'case':
                ids.extend(list(marker.args))
    return set(ids)
