import logging
import os
import signal
import subprocess
import time

import allure

import configs
from configs.system import IS_WIN

_logger = logging.getLogger(__name__)


@allure.step('Kill process')
def kill_process(pid):
    os.kill(pid, signal.SIGILL if IS_WIN else signal.SIGKILL)


@allure.step('System execute command')
def execute(
        command: list,
        shell=False if IS_WIN else True,
        stderr=subprocess.PIPE,
        stdout=subprocess.PIPE,
        check=False
):
    def _is_process_exists(_process) -> bool:
        return _process.poll() is None

    def _wait_for_execution(_process):
        while _is_process_exists(_process):
            time.sleep(1)

    def _get_output(_process):
        _wait_for_execution(_process)
        return _process.communicate()

    command = " ".join(str(atr) for atr in command)
    _logger.info(f'Execute: {command}')
    process = subprocess.Popen(command, shell=shell, stderr=stderr, stdout=stdout)
    if check and process.returncode != 0:
        stdout, stderr = _get_output(process)
        raise RuntimeError(stderr)
    return process.pid


@allure.step('System run command')
def run(
        command: list,
        shell=False if IS_WIN else True,
        stderr=subprocess.PIPE,
        stdout=subprocess.PIPE,
        timeout_sec=configs.timeouts.PROCESS_TIMEOUT_SEC,
        check=True
):
    command = " ".join(str(atr) for atr in command)
    _logger.info(f'Execute: {command}')
    process = subprocess.run(command, shell=shell, stderr=stderr, stdout=stdout, timeout=timeout_sec)
    if check and process.returncode != 0:
        raise subprocess.CalledProcessError(process.returncode, command, process.stdout, process.stderr)
    _logger.debug(f'stdout: {process.stdout}')
