import logging
import os
import signal
import subprocess
import time
from collections import namedtuple
from datetime import datetime

import psutil

import configs
from configs.system import IS_WIN

_logger = logging.getLogger(__name__)

process_info = namedtuple('RunInfo', ['pid', 'name', 'create_time'])


def find_process_by_name(process_name: str):
    processes = []
    for proc in psutil.process_iter():
        try:
            if process_name.lower().split('.')[0] == proc.name().lower().split('.')[0]:
                processes.append(process_info(
                    proc.pid,
                    proc.name(),
                    datetime.fromtimestamp(proc.create_time()).strftime("%H:%M:%S.%f"))
                )
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass
    if processes:
        _logger.debug(
            f'Process: {process_name} found in processes list, PID: {", ".join([str(proc.pid) for proc in processes])}')
    else:
        _logger.debug(f'Process: {process_name} not found in processes list')
    return processes


def kill_process_by_name(process_name: str, verify: bool = True, timeout_sec: int = 10):
    _logger.info(f'Closing process: {process_name}')
    processes = find_process_by_name(process_name)
    for process in processes:
        try:
            os.kill(process.pid, signal.SIGILL if IS_WIN else signal.SIGKILL)
        except PermissionError as err:
            _logger.info(f'Close "{process}" error: {err}')
    if verify and processes:
        wait_for_close(process_name, timeout_sec)


def wait_for_started(process_name: str, timeout_sec: int = configs.timeouts.PROCESS_TIMEOUT_SEC):
    started_at = time.monotonic()
    while True:
        process = find_process_by_name(process_name)
        if process:
            _logger.info(f'Process started: {process_name}, start time: {process[0].create_time}')
            return process[0]
        time.sleep(1)
        _logger.info(f'Waiting time: {int(time.monotonic() - started_at)} seconds')
        assert time.monotonic() - started_at < timeout_sec, f'Start process error: {process_name}'


def wait_for_close(process_name: str, timeout_sec: int = configs.timeouts.PROCESS_TIMEOUT_SEC):
    started_at = time.monotonic()
    while True:
        if not find_process_by_name(process_name):
            break
        time.sleep(1)
        assert time.monotonic() - started_at < timeout_sec, f'Close process error: {process_name}'
    _logger.info(f'Process closed: {process_name}')


def execute(
        command: list,
        shell=True,
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
    process = subprocess.Popen(command, shell=True, stderr=stderr, stdout=stdout)
    if check and process.returncode != 0:
        stdout, stderr = _get_output(process)
        raise RuntimeError(stderr)
    return process.pid


def run(
        command: list,
        shell=True,
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
