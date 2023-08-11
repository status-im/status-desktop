import os
import typing
from datetime import datetime

from scripts.utils.system_path import SystemPath

ROOT: SystemPath = SystemPath(__file__).resolve().parent.parent

# Runtime initialisation
TEST: typing.Optional[SystemPath] = None
TEST_VP: typing.Optional[SystemPath] = None
TEST_ARTIFACTS: typing.Optional[SystemPath] = None

# Test Directories
RUN_ID = os.getenv('RUN_DIR', f'run_{datetime.now():%d%m%Y_%H%M%S}')
TEMP: SystemPath = ROOT / 'tmp'
RESULTS: SystemPath = TEMP / 'results'
RUN: SystemPath = RESULTS / RUN_ID
VP: SystemPath = ROOT / 'ext' / 'vp'
TEST_FILES: SystemPath = ROOT / 'ext' / 'test_files'
TEST_USER_DATA: SystemPath = ROOT / 'ext' / 'user_data'

# Driver Directories
SQUISH_DIR = SystemPath(os.getenv('SQUISH_DIR'))

# Status Application
STATUS_DATA: SystemPath = RUN / 'status'
