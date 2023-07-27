import platform

IS_LIN = True if platform.system() == 'Linux' else False
IS_MAC = True if platform.system() == 'Darwin' else False
IS_WIN = True if platform.system() == 'Windows' else False
