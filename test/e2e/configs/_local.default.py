import logging
import os

LOG_LEVEL = logging.DEBUG
DEV_BUILD = False
AUT_PATH = "path to the application (.app or .AppImage)"
os.environ['STATUS_RUNTIME_USE_MOCKED_KEYCARD'] = 'False'

