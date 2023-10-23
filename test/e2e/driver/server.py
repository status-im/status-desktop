import logging
import typing

import configs.testpath
from scripts.utils import local_system

_PROCESS_NAME = '_squishserver'

_logger = logging.getLogger(__name__)


class SquishServer:
    __instance = None
    path = configs.testpath.SQUISH_DIR / 'bin' / 'squishserver'
    config = configs.testpath.ROOT / 'squish_server.ini'
    host = '127.0.0.1'
    port = None
    pid = None

    def __new__(cls):
        if not SquishServer.__instance:
            SquishServer.__instance = super(SquishServer, cls).__new__(cls)
        return SquishServer.__instance

    @classmethod
    def start(cls):
        cls.port = local_system.find_free_port(configs.squish.SERVER_PORT, 100)
        cmd = [
            f'"{cls.path}"',
            '--configfile', str(cls.config),
            f'--host={cls.host}',
            f'--port={cls.port}',
        ]
        cls.pid = local_system.execute(cmd)

    @classmethod
    def stop(cls):
        if cls.pid is not None:
            local_system.kill_process(cls.pid, verify=True)
            cls.pid = None
        cls.port = None

    # https://doc-snapshots.qt.io/squish/cli-squishserver.html
    @classmethod
    def configuring(cls, action: str, options: typing.Union[int, str, list]):
        local_system.run(
            [f'"{cls.path}"', '--configfile', str(cls.config), '--config', action, ' '.join(options)])

    @classmethod
    def add_executable_aut(cls, aut_id, app_dir):
        cls.configuring('addAUT', [aut_id, f'"{app_dir}"'])

    @classmethod
    def add_attachable_aut(cls, aut_id: str, port: int):
        cls.configuring('addAttachableAUT', [aut_id, f'localhost:{port}'])

    @classmethod
    def set_aut_timeout(cls, value: int = configs.timeouts.PROCESS_TIMEOUT_SEC):
        cls.configuring('setAUTTimeout', [str(value)])
