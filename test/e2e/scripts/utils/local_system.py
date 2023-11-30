import logging
import os
import signal
import subprocess
import time
import typing

import allure
import psutil

import configs
from configs.system import IS_WIN

_logger = logging.getLogger(__name__)


def find_process_by_port(port: int) -> typing.List[int]:
    pid_list = []
    for proc in psutil.process_iter():
        try:
            for conns in proc.connections(kind='inet'):
                if conns.laddr.port == port:
                    pid_list.append(proc.pid)
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass
    return pid_list


def find_free_port(start: int, step: int):
    while find_process_by_port(start):
        start+=step
    return start


def wait_for_close(pid: int, timeout_sec: int = configs.timeouts.PROCESS_TIMEOUT_SEC):
    started_at = time.monotonic()
    while True:
        for proc in psutil.process_iter():
            try:
                if proc.pid == pid:
                    return True
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                pass
        time.sleep(1)
        if time.monotonic() - started_at > timeout_sec:
            raise RuntimeError(f'Process with PID: {pid} not closed')
        else:
            break


@allure.step('Kill process')
def kill_process(pid, verify: bool = False, timeout_sec: int = configs.timeouts.PROCESS_TIMEOUT_SEC, attempt: int = 2):
    try:
        os.kill(pid, signal.SIGILL if IS_WIN else signal.SIGKILL)
    except ProcessLookupError as err:
        _logger.debug(err)
    if verify:
        try:
            wait_for_close(pid, timeout_sec)
        except RuntimeError as err:
            if attempt:
                kill_process(pid, verify, timeout_sec, attempt - 1)
            else:
                raise err


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
