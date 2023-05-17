import time

count = 2


def attempt(count):
    _count = count

    def _wrapper(method_to_decorate):

        def wrapper(*args, **kwargs):
            try:
                return method_to_decorate(*args, **kwargs)  
            except: 
            
                global count
                if count:
                    count -= 1
                    time.sleep(1)
                    return wrapper(*args, **kwargs)
                else:
                    raise

        return wrapper
    
    return _wrapper


def close_exists(element):

    def _wrapper(method_to_decorate):

        def wrapper(*args, **kwargs):
            if element.is_visible:  
                element.close()
            return method_to_decorate(*args, **kwargs)

        return wrapper
    
    return _wrapper