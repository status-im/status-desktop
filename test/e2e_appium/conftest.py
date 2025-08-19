import os
import pytest
from datetime import datetime
from pathlib import Path

from .config import setup_logging, log_test_start, log_test_end
from .config.logging_config import get_logger
from .core import EnvironmentSwitcher
from .utils.lambdatest_reporter import LambdaTestReporter


# Expose fixture modules without star imports
pytest_plugins = [
    "fixtures.onboarding_fixture",
]


_logging_setup = None


def pytest_configure(config):
    global _logging_setup
    _logging_setup = setup_logging()

    # Normalize CLI --env to CURRENT_TEST_ENVIRONMENT so all components agree
    try:
        cli_env = getattr(config.option, "env", None)
        if cli_env:
            normalized_env = (
                "lambdatest" if cli_env in ("lt", "lambdatest") else "local"
            )
            os.environ["CURRENT_TEST_ENVIRONMENT"] = normalized_env
    except Exception:
        # Do not block test runs if normalization fails
        pass

    # Use YAML-based configuration
    env_name = os.getenv("CURRENT_TEST_ENVIRONMENT", "lambdatest")

    try:
        switcher = EnvironmentSwitcher()
        env_config = switcher.switch_to(env_name)

        # Use directories from YAML config
        reports_dir = Path(env_config.directories.get("reports", "reports"))
        enable_xml_report = env_config.logging_config.get("enable_xml_report", True)
        enable_html_report = env_config.logging_config.get("enable_html_report", True)

        logger = get_logger("conftest")
        logger.info(f"📁 Using reports directory from {env_name} config: {reports_dir}")

    except Exception as e:
        # Simplified fallback using defaults
        reports_dir = Path("reports")
        enable_xml_report = True
        enable_html_report = True

        logger = get_logger("conftest")
        logger.warning(f"⚠️ Using default configuration: {e}")
        logger.warning("💡 Ensure YAML config files are properly set up")

    reports_dir.mkdir(exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    if not hasattr(config.option, "xmlpath") or not config.option.xmlpath:
        if enable_xml_report:
            xml_report = reports_dir / f"pytest_results_{timestamp}.xml"
            config.option.xmlpath = str(xml_report)

    if not hasattr(config.option, "htmlpath") or not config.option.htmlpath:
        if enable_html_report:
            html_report = reports_dir / f"pytest_report_{timestamp}.html"
            config.option.htmlpath = str(html_report)
            config.option.self_contained_html = True

    logger = _logging_setup["loggers"]["main"] if _logging_setup else None
    if logger:
        logger.info("📊 Automatic report generation enabled:")
        if hasattr(config.option, "xmlpath") and config.option.xmlpath:
            logger.info(f"  📄 XML Report: {config.option.xmlpath}")
        if hasattr(config.option, "htmlpath") and config.option.htmlpath:
            logger.info(f"  🌐 HTML Report: {config.option.htmlpath}")


def pytest_addoption(parser):
    parser.addoption(
        "--env",
        action="store",
        default="lt",
        help="Test environment: local or lt (LambdaTest)",
    )


@pytest.fixture(scope="session")
def test_environment(request):
    return request.config.getoption("--env")


@pytest.fixture(scope="function")
def performance_tracker(request):
    if not _logging_setup:
        return None

    tracker = _logging_setup["performance_tracker"]()

    if hasattr(tracker, "context"):
        tracker.context = tracker.context or {}
        tracker.context.update(
            {
                "test_name": request.node.name,
                "test_module": request.node.module.__name__
                if request.node.module
                else "unknown",
            }
        )

    return tracker


def pytest_runtest_setup(item):
    test_name = item.name
    test_file = item.location[0] if item.location else "unknown"

    log_test_start(
        test_name,
        test_file=test_file,
        markers=[mark.name for mark in item.iter_markers()],
    )


def pytest_runtest_teardown(item, nextitem):
    test_name = item.name

    # Determine test success from the test result
    success = True
    duration_ms = 0

    if hasattr(item, "rep_call"):
        success = item.rep_call.passed

    if hasattr(item, "_test_start_time"):
        duration = datetime.now() - item._test_start_time
        duration_ms = int(duration.total_seconds() * 1000)

    log_test_end(test_name, success, duration_ms)


@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    rep = outcome.get_result()

    setattr(item, "rep_" + rep.when, rep)

    # Report setup/call/teardown so setup failures are reflected in LT
    if rep.when in ("setup", "call", "teardown"):
        try:
            LambdaTestReporter.report_test_result(item, rep)
        except Exception as e:
            logger = get_logger("session")
            logger.error(f"Failed to report test result to LambdaTest: {e}")

def pytest_terminal_summary(terminalreporter, exitstatus, config):
    if not _logging_setup:
        return

    logger = _logging_setup["loggers"]["main"]

    passed = len(terminalreporter.stats.get("passed", []))
    failed = len(terminalreporter.stats.get("failed", []))
    skipped = len(terminalreporter.stats.get("skipped", []))
    errors = len(terminalreporter.stats.get("error", []))

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
    if hasattr(config.option, "xmlpath") and config.option.xmlpath:
        xml_file = Path(config.option.xmlpath)
        if xml_file.exists():
            logger.info(f"  📄 XML Report: {xml_file}")
        else:
            logger.warning(f"  ⚠️ XML Report expected but not found: {xml_file}")

    if hasattr(config.option, "htmlpath") and config.option.htmlpath:
        html_file = Path(config.option.htmlpath)
        if html_file.exists():
            logger.info(f"  🌐 HTML Report: {html_file}")
        else:
            logger.warning(f"  ⚠️ HTML Report expected but not found: {html_file}")

    logger.info("=" * 60)

    if failed > 0:
        logger.warning(f"⚠️ {failed} test(s) failed. Check reports for details.")

        failed_tests = terminalreporter.stats.get("failed", [])
        for test_report in failed_tests[:5]:
            test_name = test_report.nodeid.split("::")[-1]
            if hasattr(test_report, "longrepr") and test_report.longrepr:
                error_msg = (
                    str(test_report.longrepr).split("\n")[-2]
                    if test_report.longrepr
                    else "Unknown error"
                )
                logger.error(f"  ❌ {test_name}: {error_msg}")

        if len(failed_tests) > 5:
            logger.error(f"  ... and {len(failed_tests) - 5} more failures")

    if errors > 0:
        logger.error(f"💥 {errors} test(s) had errors. Check reports for details.")

        error_tests = terminalreporter.stats.get("error", [])
        for test_report in error_tests[:3]:
            test_name = test_report.nodeid.split("::")[-1]
            if hasattr(test_report, "longrepr") and test_report.longrepr:
                error_msg = (
                    str(test_report.longrepr).split("\n")[-2]
                    if test_report.longrepr
                    else "Unknown error"
                )
                logger.error(f"  💥 {test_name}: {error_msg}")

        if len(error_tests) > 3:
            logger.error(f"  ... and {len(error_tests) - 3} more errors")

    if passed == total and total > 0:
        logger.info("🎉 All tests passed successfully!")

    logger.info("=" * 60)
