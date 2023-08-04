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
        cmd = [
            f'"{self.path}"',
            '--configfile', str(self.config),
            '--verbose',
            f'--host={self.host}',
            f'--port={self.port}',
        ]
        local_system.execute(cmd)
        try:
            local_system.wait_for_started(_PROCESS_NAME)
        except AssertionError:
            local_system.execute(cmd, check=True)

    @classmethod
    def stop(cls, attempt: int = 2):
        local_system.kill_process_by_name(_PROCESS_NAME, verify=False)

    # https://doc-snapshots.qt.io/squish/cli-squishserver.html
    def configuring(self, action: str, options: typing.Union[int, str, list]):
        local_system.run(
            [f'"{self.path}"', '--configfile', str(self.config), '--config', action, ' '.join(options)])

    def add_executable_aut(self, aut_id, app_dir):
        self.configuring('addAUT', [aut_id, f'"{app_dir}"'])

    def add_attachable_aut(self, aut_id: str, port: int):
        self.configuring('addAttachableAUT', [aut_id, f'localhost:{port}'])

    def set_aut_timeout(self, value: int = configs.timeouts.PROCESS_TIMEOUT_SEC):
        self.configuring('setAUTTimeout', [str(value)])
