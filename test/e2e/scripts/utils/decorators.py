import logging
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
