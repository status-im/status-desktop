from functools import wraps


def close_exists(element):
    def _wrapper(method_to_decorate):
        def wrapper(*args, **kwargs):
            if element.is_visible:
                element.close()
            return method_to_decorate(*args, **kwargs)

        return wrapper

    return _wrapper


def handle_settings_opening(view_class, menu_item):
    def open_settings_decorator(func):
        @wraps(func)
        def wrapper(self, click_attempts=2):
            self._open_settings(menu_item)
            try:
                return func(self)
            except (LookupError, AssertionError) as ex:
                if click_attempts:
                    return func(self, click_attempts - 1)
                else:
                    raise ex

        return wrapper

    return open_settings_decorator
