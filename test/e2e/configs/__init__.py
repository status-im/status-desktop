import logging

from . import testpath, timeouts

_logger = logging.getLogger(__name__)

try:
    from ._local import *
except ImportError:
    exit(
        'Config file: "_local.py" not found in "./configs".\n'
        'Please use template "_.local.py.default" to create file or execute command: \n'
        rf'cp {testpath.ROOT}/configs/_local.py.default {testpath.ROOT}/configs/_local.py'
    )
