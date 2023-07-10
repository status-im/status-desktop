import logging
import os
import pathlib
import shutil

_logger = logging.getLogger(__name__)


class SystemPath(pathlib.Path):
    _accessor = pathlib._normal_accessor  # noqa
    _flavour = pathlib._windows_flavour if os.name == 'nt' else pathlib._posix_flavour  # noqa

    def rmtree(self, ignore_errors=False):
        shutil.rmtree(self, ignore_errors=ignore_errors)
