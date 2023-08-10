import logging
import os
import signal
import subprocess
import time
from collections import namedtuple
from datetime import datetime

import allure
import psutil

import configs
from configs.system import IS_WIN

_logger = logging.getLogger(__name__)

process_info = namedtuple('RunInfo', ['pid', 'name', 'create_time'])


@allure.step('Find process by name')
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
    return processes


@allure.step('Find process by pid')
def find_process_by_pid(pid):
    for proc in psutil.process_iter():
        try:
            if proc.pid == pid:
                return process_info(
                    proc.pid,
                    proc.name(),
                    datetime.fromtimestamp(proc.create_time()).strftime("%H:%M:%S.%f")
                )
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass


@allure.step('Find process by port')
def find_process_by_port(port: int):
    for proc in psutil.process_iter():
        try:
            for conns in proc.connections(kind='inet'):
                if conns.laddr.port == port:
                    return process_info(
                        proc.pid,
                        proc.name(),
                        datetime.fromtimestamp(proc.create_time()).strftime("%H:%M:%S.%f")
                    )
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass


@allure.step('Kill process by name')
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


@allure.step('Kill process by PID')
def kill_process_by_pid(pid, verify: bool = True, timeout_sec: int = 10):
    os.kill(pid, signal.SIGILL if IS_WIN else signal.SIGKILL)
    if verify:
        wait_for_close(pid=pid, timeout_sec=timeout_sec)


@allure.step('Kill process by port')
def kill_process_by_port(port: int):
    proc = find_process_by_port(port)
    if proc is not None and proc.pid:
        kill_process_by_pid(proc.pid)


@allure.step('Wait for process start')
def wait_for_started(process_name: str = None, timeout_sec: int = configs.timeouts.PROCESS_TIMEOUT_SEC):
    started_at = time.monotonic()
    while True:
        process = find_process_by_name(process_name)
        if process:
            _logger.info(f'Process started: {process_name}, start time: {process[0].create_time}')
            return process[0]
        time.sleep(1)
        _logger.debug(f'Waiting time: {int(time.monotonic() - started_at)} seconds')
        assert time.monotonic() - started_at < timeout_sec, f'Start process error: {process_name}'


@allure.step('Wait for process close')
def wait_for_close(process_name: str = None, timeout_sec: int = configs.timeouts.PROCESS_TIMEOUT_SEC, pid=None):
    started_at = time.monotonic()
    while True:
        if process_name is not None:
            process = find_process_by_name(process_name)
            if not process:
                break
        elif pid is not None:
            process = find_process_by_pid(pid)
            if process is None:
                break
        else:
            raise RuntimeError('Set process name or PID to find process')
        time.sleep(1)
        assert time.monotonic() - started_at < timeout_sec, f'Close process error: {process_name or pid}'
    _logger.info(f'Process closed: {process_name}')


@allure.step('System execute command')
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
    process = subprocess.Popen(command, shell=shell, stderr=stderr, stdout=stdout)
    if check and process.returncode != 0:
        stdout, stderr = _get_output(process)
        raise RuntimeError(stderr)
    return process.pid


@allure.step('System run command')
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
    _logger.debug(f'stdout: {process.stdout}')
