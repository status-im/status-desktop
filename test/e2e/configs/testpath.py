import os
from datetime import datetime

from scripts.utils.system_path import SystemPath

ROOT: SystemPath = SystemPath(__file__).resolve().parent.parent

# Test Directories
RUN_ID = os.getenv('RUN_DIR', f'run_{datetime.now():%d%m%Y_%H%M%S}')
TEMP: SystemPath = ROOT / 'tmp'
RESULTS: SystemPath = TEMP / 'results'
RUN: SystemPath = RESULTS / RUN_ID

# Driver Directories
SQUISH_DIR = os.getenv('RUN_DIR')
