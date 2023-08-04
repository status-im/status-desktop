import logging

from scripts.utils.system_path import SystemPath
from . import testpath, timeouts, testrail, system

_logger = logging.getLogger(__name__)

try:
    from ._local import *
except ImportError:
    exit(
        'Config file: "_local.py" not found in "./configs".\n'
        'Please use template "_.local.py.default" to create file or execute command: \n'
        rf'cp {testpath.ROOT}/configs/_local.py.default {testpath.ROOT}/configs/_local.py'
    )

if APP_DIR is None:
    exit('Please add "APP_DIR" in ./configs/_local.py')
if system.IS_WIN and 'bin' not in APP_DIR:
    exit('Please use launcher from "bin" folder in "APP_DIR"')
APP_DIR = SystemPath(APP_DIR)
