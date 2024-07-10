import os
import platform


def get_platform():
    return platform.system()


DISPLAY = os.getenv('DISPLAY', ':0')

TEST_MODE = os.getenv('STATUS_RUNTIME_TEST_MODE')
CLOSE_KEYCARD_CONTROLLER = True

