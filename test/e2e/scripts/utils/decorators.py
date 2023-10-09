def close_exists(element):
    def _wrapper(method_to_decorate):
        def wrapper(*args, **kwargs):
            if element.is_visible:
                element.close()
            return method_to_decorate(*args, **kwargs)

        return wrapper

    return _wrapper
