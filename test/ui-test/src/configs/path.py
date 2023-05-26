import os

from utils.system_path import SystemPath

ROOT: SystemPath = SystemPath(__file__).resolve().parent.parent.parent
TMP: SystemPath = ROOT / 'tmp'

AUT: SystemPath = SystemPath(os.getenv('AUT_PATH', ROOT.parent.parent / 'bin' / 'nim_status_client'))
STATUS_DATA_FOLDER_NAME = 'Status'
