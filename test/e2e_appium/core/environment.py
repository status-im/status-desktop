import os
import re
from dataclasses import dataclass
from typing import Dict, Any
from pathlib import Path


class ConfigurationError(Exception):
    pass


@dataclass
class EnvironmentConfig:
    environment: str
    device_name: str
    platform_name: str
    platform_version: str
    app_source: Dict[str, Any]
    appium_config: Dict[str, Any]
    capabilities: Dict[str, Any]
    timeouts: Dict[str, int]
    directories: Dict[str, str]
    logging_config: Dict[str, Any]
    
    def validate(self) -> None:
        if self.environment == "local":
            self._validate_local_config()
        elif self.environment == "lambdatest":  
            self._validate_lambdatest_config()
    
    def _validate_local_config(self):
        app_path = self.app_source.get('path_template', '')
        resolved_path = self._resolve_template(app_path)
        
        if resolved_path and not Path(resolved_path).exists():
            raise ConfigurationError(f"Local app not found: {resolved_path}")
        
        try:
            import requests
            server_url = self.appium_config.get('server_url', 'http://localhost:4723')
            response = requests.get(f"{server_url}/status", timeout=5)
            if response.status_code != 200:
                raise ConfigurationError("Appium server not responding correctly")
        except requests.RequestException:
            raise ConfigurationError("Cannot connect to Appium server")
    
    def _validate_lambdatest_config(self):
        required_vars = ['LT_USERNAME', 'LT_ACCESS_KEY']
        missing = [var for var in required_vars if not os.getenv(var)]
        
        if missing:
            raise ConfigurationError(f"Missing LambdaTest variables: {missing}")
            
        app_id = self.app_source.get('app_id_template', '')
        resolved_app_id = self._resolve_template(app_id)
        if not resolved_app_id or resolved_app_id == 'lt://':
            raise ConfigurationError("STATUS_APP_URL must be provided for LambdaTest")
    
    def _resolve_template(self, template: str) -> str:
        if not template:
            return ""
            
        def replace_var(match):
            var_name = match.group(1)
            default = match.group(2) if match.group(2) else ""
            return os.getenv(var_name, default)
        
        return re.sub(r'\$\{([^}:]+)(?::([^}]*))?\}', replace_var, template)
    
    def get_resolved_app_path(self) -> str:
        if self.app_source['source_type'] == 'local_file':
            return self._resolve_template(self.app_source['path_template'])
        elif self.app_source['source_type'] == 'cloud_upload':
            return self._resolve_template(self.app_source['app_id_template'])
        return ""
    
    def get_appium_server_url(self) -> str:
        return self.appium_config['server_url']
    
    def get_device_capabilities(self) -> Dict[str, Any]:
        base_caps = {
            'platformName': self.platform_name,
            'platformVersion': self.platform_version,
            'deviceName': self.device_name
        }
        
        if self.environment == "local":
            base_caps['app'] = self.get_resolved_app_path()
        
        base_caps.update(self.capabilities)
        return base_caps 