import os
import pathlib


class SystemPath(pathlib.Path):
    _accessor = pathlib._normal_accessor  # noqa
    _flavour = pathlib._windows_flavour if os.name == 'nt' else pathlib._posix_flavour  # noqa

    def rmtree(self, ignore_errors=False):
        try:
            children = list(self.iterdir())
            for child in children:
                if child.is_dir():
                    child.rmtree(ignore_errors=ignore_errors)
                else:
                    try:
                        child.unlink()
                    except OSError as e:
                        if not ignore_errors:
                            raise
        
            self.rmdir()
        except (FileNotFoundError, OSError):
            if not ignore_errors:
                raise
