import sys

import pytest

from .test_data_manager import TestDataManager
from config.logging_config import get_logger


class BaseTest:
    
    def setup_method(self, method):
        # Initialize logger for test instance
        self.logger = get_logger('tests')
        
        # Get environment from pytest config or environment variable
        import os
        test_env = os.getenv('CURRENT_TEST_ENVIRONMENT', 'lambdatest')
        
        # Try to get environment from pytest if available
        if hasattr(self, 'request') and hasattr(self.request, 'config'):
            test_env = self.request.config.getoption('--env', default=test_env)
        
        self.test_data_manager = TestDataManager(test_env)
        self.driver = self.test_data_manager.get_driver()
        self.test_name = method.__name__
        
        if not hasattr(self.__class__, '_active_drivers'):
            self.__class__._active_drivers = {}
        self.__class__._active_drivers[id(self)] = self.driver
        
        try:
            self.session_id = self.driver.session_id
        except:
            self.session_id = 'unknown_session'
    
    def teardown_method(self, method):
        if hasattr(self, 'test_data_manager') and self.driver:
            try:
                pass
            except Exception as e:
                logger = get_logger('session')
                logger.error(f"⚠️ Error in teardown: {e}", extra={'error': str(e), 'test_name': self.test_name})
            finally:
                # Remove from active drivers dict before cleanup
                if hasattr(self.__class__, '_active_drivers'):
                    self.__class__._active_drivers.pop(id(self), None)
                
                # Clean up driver
                self.test_data_manager.cleanup_driver()
    
    @classmethod
    def _report_to_lambdatest(cls, driver, test_name, test_passed, error_message=None):
        logger = get_logger('session')
        
        try:
            status = "passed" if test_passed else "failed"
            
            driver.execute_script(f"lambda-status={status}")
            
            driver.execute_script(f"lambda-name={test_name}")
            
            if not test_passed and error_message:
                clean_error = error_message.replace('"', '\\"').replace('\n', '\\n')[:500]
                driver.execute_script(f"lambda-description=Test failed: {clean_error}")
            
            log_data = {
                'test_name': test_name,
                'lambdatest_status': status,
                'success': test_passed
            }
            
            if error_message:
                log_data['error_message'] = error_message[:200]
            
            if test_passed:
                logger.info(
                    f"✅ LambdaTest Report: {test_name} = PASSED",
                    extra=log_data
                )
            else:
                logger.warning(
                    f"❌ LambdaTest Report: {test_name} = FAILED",
                    extra=log_data
                )
                if error_message:
                    logger.error(
                        f"   Error Details: {error_message[:200]}...",
                        extra={'test_name': test_name, 'full_error': error_message}
                    )
                
        except Exception as e:
            logger.error(
                f"⚠️ Failed to report test status to LambdaTest: {e}",
                extra={
                    'test_name': test_name,
                    'error': str(e),
                    'reporting_failure': True
                }
            )
    
    @classmethod
    def get_active_driver_for_test(cls, test_instance_id):
        if hasattr(cls, '_active_drivers'):
            return cls._active_drivers.get(test_instance_id)
        return None 


class BaseTestCase(BaseTest):
    pass


class OnboardingTestCase(BaseTest):
    
    def setup_method(self, method):
        super().setup_method(method)
        self.onboarding_context = {
            'test_type': 'onboarding',
            'started_at': method.__name__
        } 