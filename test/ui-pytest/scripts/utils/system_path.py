import logging
import os
import pathlib
import shutil

import allure

_logger = logging.getLogger(__name__)


class SystemPath(pathlib.Path):
    _accessor = pathlib._normal_accessor  # noqa
    _flavour = pathlib._windows_flavour if os.name == 'nt' else pathlib._posix_flavour  # noqa

    @allure.step('Delete path')
    def rmtree(self, ignore_errors=False):
        shutil.rmtree(self, ignore_errors=ignore_errors)

    @allure.step('Copy path')
    def copy_to(self, destination: 'SystemPath'):
        shutil.copytree(self, destination, dirs_exist_ok=True)
