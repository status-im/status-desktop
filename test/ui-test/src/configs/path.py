import os

from utils.system_path import SystemPath

ROOT: SystemPath = SystemPath(__file__).resolve().parent.parent.parent
TMP: SystemPath = ROOT / 'tmp'

AUT: SystemPath = SystemPath(os.getenv('AUT_PATH', ROOT.parent.parent / 'bin' / 'nim_status_client'))
STATUS_APP_DATA = TMP / 'Status'
STATUS_USER_DATA: SystemPath = STATUS_APP_DATA / 'data'
