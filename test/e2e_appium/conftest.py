import os
import pytest
from datetime import datetime
from pathlib import Path

from .config import setup_logging, log_test_start, log_test_end, get_config
from .config.logging_config import get_logger
from .core import EnvironmentSwitcher


_logging_setup = None


def pytest_configure(config):
    global _logging_setup
    _logging_setup = setup_logging()
    
    # Try to use new YAML-based configuration, fallback to old system
    try:
        env_name = os.getenv('CURRENT_TEST_ENVIRONMENT', 'lambdatest')
        switcher = EnvironmentSwitcher()
        env_config = switcher.switch_to(env_name)
        
        # Use directories from YAML config
        reports_dir = Path(env_config.directories.get('reports', 'reports'))
        enable_xml_report = env_config.logging_config.get('enable_xml_report', True)
        enable_html_report = env_config.logging_config.get('enable_html_report', True)
        
        logger = get_logger('conftest')
        logger.info(f"📁 Using reports directory from {env_name} config: {reports_dir}")
        
    except Exception as e:
        # Fallback to legacy configuration
        test_config = get_config()
        reports_dir = Path(test_config.reports_dir)
        enable_xml_report = test_config.enable_xml_report
        enable_html_report = test_config.enable_html_report
        
        logger = get_logger('conftest')
        logger.warning(f"⚠️ Using legacy configuration for reports: {e}")
    
    reports_dir.mkdir(exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    if not hasattr(config.option, 'xmlpath') or not config.option.xmlpath:
        if enable_xml_report:
            xml_report = reports_dir / f"pytest_results_{timestamp}.xml"
            config.option.xmlpath = str(xml_report)
    
    if not hasattr(config.option, 'htmlpath') or not config.option.htmlpath:
        if enable_html_report:
            html_report = reports_dir / f"pytest_report_{timestamp}.html"
            config.option.htmlpath = str(html_report)
            config.option.self_contained_html = True
    
    logger = _logging_setup['loggers']['main'] if _logging_setup else None
    if logger:
        logger.info("📊 Automatic report generation enabled:")
        if hasattr(config.option, 'xmlpath') and config.option.xmlpath:
            logger.info(f"  📄 XML Report: {config.option.xmlpath}")
        if hasattr(config.option, 'htmlpath') and config.option.htmlpath:
            logger.info(f"  🌐 HTML Report: {config.option.htmlpath}")


def pytest_addoption(parser):
    parser.addoption(
        "--env", 
        action="store", 
        default="lt", 
        help="Test environment: local or lt (LambdaTest)"
    )


@pytest.fixture(scope="session")
def test_environment(request):
    return request.config.getoption("--env")


@pytest.fixture(scope="function")
def performance_tracker(request):
    if not _logging_setup:
        return None
    
    tracker = _logging_setup['performance_tracker']()
    
    if hasattr(tracker, 'context'):
        tracker.context = tracker.context or {}
        tracker.context.update({
            'test_name': request.node.name,
            'test_module': request.node.module.__name__ if request.node.module else 'unknown'
        })
    
    return tracker


def pytest_runtest_setup(item):
    test_name = item.name
    test_file = item.location[0] if item.location else "unknown"
    
    log_test_start(
        test_name,
        test_file=test_file,
        markers=[mark.name for mark in item.iter_markers()]
    )


def pytest_runtest_teardown(item, nextitem):
    test_name = item.name
    
    # Determine test success from the test result
    success = True
    duration_ms = 0
    
    if hasattr(item, 'rep_call'):
        success = item.rep_call.passed
    
    if hasattr(item, '_test_start_time'):
        duration = datetime.now() - item._test_start_time
        duration_ms = int(duration.total_seconds() * 1000)
    
    log_test_end(test_name, success, duration_ms)


@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    rep = outcome.get_result()
    
    setattr(item, "rep_" + rep.when, rep)
    
    if rep.when == "call":
        try:
            _report_test_result_to_lambdatest(item, rep)
        except Exception as e:
            logger = get_logger('session')
            logger.error(f"Failed to report test result to LambdaTest: {e}")


def pytest_terminal_summary(terminalreporter, exitstatus, config):
    if not _logging_setup:
            return
            
    logger = _logging_setup['loggers']['main']
    
    passed = len(terminalreporter.stats.get('passed', []))
    failed = len(terminalreporter.stats.get('failed', []))
    skipped = len(terminalreporter.stats.get('skipped', []))
    errors = len(terminalreporter.stats.get('error', []))
    
    total = passed + failed + skipped + errors
    
    logger.info("=" * 60)
    logger.info("🎯 TEST EXECUTION SUMMARY")
    logger.info("=" * 60)
    logger.info(f"Total Tests: {total}")
    logger.info(f"✅ Passed: {passed}")
    logger.info(f"❌ Failed: {failed}")
    logger.info(f"⏭️  Skipped: {skipped}")
    logger.info(f"💥 Errors: {errors}")
    
    if total > 0:
        success_rate = (passed / total) * 100
        logger.info(f"📊 Success Rate: {success_rate:.1f}%")
    
    logger.info("Reports Generated:")
    if hasattr(config.option, 'xmlpath') and config.option.xmlpath:
        xml_file = Path(config.option.xmlpath)
        if xml_file.exists():
            logger.info(f"  📄 XML Report: {xml_file}")
        else:
            logger.warning(f"  ⚠️ XML Report expected but not found: {xml_file}")
    
    if hasattr(config.option, 'htmlpath') and config.option.htmlpath:
        html_file = Path(config.option.htmlpath)
        if html_file.exists():
            logger.info(f"  🌐 HTML Report: {html_file}")
        else:
            logger.warning(f"  ⚠️ HTML Report expected but not found: {html_file}")
    
    logger.info("=" * 60)
    
    if failed > 0:
        logger.warning(f"⚠️ {failed} test(s) failed. Check reports for details.")
        
        failed_tests = terminalreporter.stats.get('failed', [])
        for test_report in failed_tests[:5]:
            test_name = test_report.nodeid.split("::")[-1]
            if hasattr(test_report, 'longrepr') and test_report.longrepr:
                error_msg = str(test_report.longrepr).split('\n')[-2] if test_report.longrepr else "Unknown error"
                logger.error(f"  ❌ {test_name}: {error_msg}")
        
        if len(failed_tests) > 5:
            logger.error(f"  ... and {len(failed_tests) - 5} more failures")
    
    if errors > 0:
        logger.error(f"💥 {errors} test(s) had errors. Check reports for details.")
        
        error_tests = terminalreporter.stats.get('error', [])
        for test_report in error_tests[:3]:
            test_name = test_report.nodeid.split("::")[-1]
            if hasattr(test_report, 'longrepr') and test_report.longrepr:
                error_msg = str(test_report.longrepr).split('\n')[-2] if test_report.longrepr else "Unknown error"
                logger.error(f"  💥 {test_name}: {error_msg}")
        
        if len(error_tests) > 3:
            logger.error(f"  ... and {len(error_tests) - 3} more errors")
    
    if passed == total and total > 0:
        logger.info("🎉 All tests passed successfully!")
    
    logger.info("=" * 60)


def _report_test_result_to_lambdatest(item, test_report):
    """
    Emergency backup LambdaTest result reporting via pytest hooks.
    
    Only reports if BaseTest teardown didn't handle it (e.g., test crashed).
    Prevents double reporting by checking if reporting already occurred.
    """
    test_name = item.name
    test_passed = test_report.passed
    error_message = None
    
    if test_report.failed and hasattr(test_report, 'longrepr'):
        error_message = str(test_report.longrepr)
    
    try:
        from .tests.base_test import BaseTest
        test_instance_id = id(item.instance) if hasattr(item, 'instance') else None
        
        if test_instance_id:
            # Check if BaseTest already handled reporting
            test_instance = item.instance if hasattr(item, 'instance') else None
            if test_instance and hasattr(test_instance, '_result_reported') and test_instance._result_reported:
                # BaseTest already handled reporting, skip
                logger = get_logger('session')
                logger.debug(f"Skipping pytest hook reporting for {test_name} - already reported by BaseTest")
                return
            
            driver = BaseTest.get_active_driver_for_test(test_instance_id)
            if driver:
                BaseTest._report_to_lambdatest(driver, test_name, test_passed, error_message)
                logger = get_logger('session')
                logger.info(f"📋 Fallback result reporting: {test_name} = {'PASSED' if test_passed else 'FAILED'}")
            else:
                # Only warn for failed tests - passed tests may have already cleaned up
                if not test_passed:
                    logger = get_logger('session')
                    logger.warning(f"⚠️ No active driver found for failed test: {test_name}")
        else:
            # Only warn for failed tests - passed tests may have already cleaned up
            if not test_passed:
                logger = get_logger('session')
                logger.warning(f"⚠️ No test instance found for failed test: {test_name}")
        
    except Exception as e:
        logger = get_logger('session')
        logger.error(f"⚠️ Error reporting to LambdaTest: {e}", extra={'test_name': test_name, 'error': str(e)}) 