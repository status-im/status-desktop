import platform

IS_LIN = True if platform.uname() == 'Linux' else False
IS_MAC = True if platform.uname() == 'Darwin' else False
IS_WIN = True if platform.system() == 'Windows' else False
