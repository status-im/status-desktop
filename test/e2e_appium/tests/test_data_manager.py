import os
import json
from appium import webdriver
from appium.options.common import AppiumOptions
from appium.webdriver.appium_connection import AppiumConnection
from selenium.webdriver.remote.client_config import ClientConfig

try:
    from config import get_config, TestConfig, get_logger, log_session_info
except ImportError:
    from config import get_config, TestConfig, get_logger, log_session_info


class TestDataManager:
    
    def __init__(self, environment="lambdatest"):
        self.environment = environment
        self.driver = None
        self.logger = get_logger('session')
        
        self.config = get_config()
        
        self.logger.info(f"✅ Configuration loaded for {environment}")
        self.logger.info(f"   Device: {self.config.device_name} ({self.config.platform_name} {self.config.platform_version})")
        self.logger.info(f"   LambdaTest User: {self.config.lt_username}")
        self.logger.info(f"   App URL: {self.config.status_app_url}")
    
    def get_driver(self):
        if self.driver:
            return self.driver
            
        if self.environment in ["lt", "lambdatest"]:
            self.driver = self._create_lambdatest_driver()
        elif self.environment == "local":
            self.driver = self._create_local_driver()
        else:
            raise ValueError(f"Unsupported environment: {self.environment}")
            
        return self.driver
    
    def _create_lambdatest_driver(self):
        options = AppiumOptions()
        
        capabilities = self.config.get_lambdatest_capabilities()
        options.load_capabilities(capabilities)
        
        client_config = ClientConfig(
            remote_server_addr=self.config.lt_hub_url,
            username=self.config.lt_username,
            password=self.config.lt_access_key
        )
        
        driver = webdriver.Remote(
            command_executor=AppiumConnection(client_config=client_config),
            options=options
        )
        
        session_id = driver.session_id if driver else "unknown"
        log_session_info(session_id, "created", environment=self.environment)
        
        return driver
    
    def _create_local_driver(self):
        options = AppiumOptions()
        
        capabilities = self.config.get_local_capabilities()
        options.load_capabilities(capabilities)
        
        return webdriver.Remote(self.config.local_appium_server, options=options)
    
    def cleanup_driver(self):
        if self.driver:
            session_id = self.driver.session_id if hasattr(self.driver, 'session_id') else "unknown"
            log_session_info(session_id, "cleanup", environment=self.environment)
            self.driver.quit()
            self.driver = None
    
    def get_configuration_summary(self):
        return self.config.summary() 