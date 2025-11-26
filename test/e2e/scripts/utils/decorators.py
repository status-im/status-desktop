import logging
import time
from functools import wraps

LOG = logging.getLogger(__name__)


def close_exists(element):
    def _wrapper(method_to_decorate):
        def wrapper(*args, **kwargs):
            if element.is_visible:
                element.close()
            return method_to_decorate(*args, **kwargs)

        return wrapper

    return _wrapper


def retry_settings(view_class, menu_item):
    def open_popup_decorator(func):
        @wraps(func)
        def wrapper(self, *args, **kwargs):
            attempts = 3
            last_exception = None
            for _ in range(1, attempts + 1):
                try:
                    LOG.info(f"Attempt # {_} to open {menu_item}")
                    self._open_settings(menu_item)
                    return func(self, *args, **kwargs)
                except Exception as ex:
                    LOG.info(f"Exception on attempt # {_}: {ex}")
                    last_exception = ex
            raise LookupError(f'Could not open settings screen within clicking {menu_item}') from last_exception

        return wrapper

    return open_popup_decorator


def open_with_retries(screen_class, attempts: int = 3, delay: float = 0.5):
    def decorator(func):
        @wraps(func)
        def wrapper(self, *args, **kwargs):
            last_exception = None
            # TODO: https://github.com/status-im/status-desktop/issues/18888
            # Workaround for app freeze when opening settings
            is_settings_screen = screen_class.__name__ == 'SettingsScreen'
            
            for attempt in range(1, attempts + 1):
                try:
                    LOG.info(f'Attempt #{attempt} to open {screen_class.__name__}')
                    button = func(self, *args, **kwargs)
                    # if is_settings_screen:
                        # # Additional wait before click for SettingsScreen due to app freeze issue
                        # time.sleep(3)
                    button.click()
                    # if is_settings_screen:
                        # # Additional wait after click for SettingsScreen due to app freeze issue
                        # time.sleep(3)
                    popup = screen_class().wait_until_appears()
                    return popup
                except Exception as e:
                    LOG.info(f'Failed to open {screen_class.__name__} with {e}')
                    last_exception = e
                    time.sleep(delay)
            raise Exception(f"Failed to open {screen_class.__name__} after {attempts} attempts: {last_exception}")
        return wrapper
    return decorator
