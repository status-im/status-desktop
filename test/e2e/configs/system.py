import os
import platform

IS_LIN = True if platform.system() == 'Linux' else False
IS_MAC = True if platform.system() == 'Darwin' else False
IS_WIN = True if platform.system() == 'Windows' else False

OS_ID = 'lin' if IS_LIN else 'mac' if IS_MAC else 'win'

DISPLAY = os.getenv('DISPLAY', ':0')

TEST_MODE = os.getenv('STATUS_RUNTIME_TEST_MODE')
