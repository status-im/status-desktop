import typing

import configs.testpath
from scripts.utils import local_system

_PROCESS_NAME = '_squishserver'


class SquishServer:

    def __init__(
            self,
            host: str = '127.0.0.1',
            port: int = 4322
    ):
        self.path = configs.testpath.SQUISH_DIR / 'bin' / 'squishserver'
        self.config = configs.testpath.ROOT / 'squish_server.ini'
        self.host = host
        self.port = port

    def start(self):
        local_system.execute([str(self.path), '--configfile', str(self.config), f'--port={self.port}'])

    @classmethod
    def stop(cls):
        local_system.execute(['killall', _PROCESS_NAME], configs.timeouts.PROCESS_TIMEOUT_SEC)

    # https://doc-snapshots.qt.io/squish/cli-squishserver.html
    def configuring(self, action: str, options: typing.Union[int, str, list]):
        local_system.execute([str(self.path), '--configfile', str(self.config), '--config', action, ' '.join(options)],
                             timeout_sec=configs.timeouts.PROCESS_TIMEOUT_SEC)

    def add_executable_aut(self, aut_id, app_dir):
        return self.configuring('addAUT', [aut_id, f'"{app_dir}"'])

    def add_attachable_aut(self, aut_id: str, port: int):
        return self.configuring('addAttachableAUT', [aut_id, f'localhost: {port}'])
