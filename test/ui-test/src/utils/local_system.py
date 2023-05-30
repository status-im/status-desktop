import os
import signal
import subprocess
import time

import configs


def get_pid(process_name: str):
    pid_list = []
    for line in os.popen("ps ax | grep " + process_name + " | grep -v grep"):
        pid_list.append(int(line.split()[0]))
    return pid_list


def kill_process(process_name: str, verify: bool = True, timeout_sec: int = configs.squish.PROCESS_TIMEOUT_SEC):
    pid_list = get_pid(process_name)
    for pid in pid_list:
        os.kill(pid, signal.SIGKILL)
    if verify:
        wait_for_close(process_name, timeout_sec)


def wait_for_started(process_name: str, timeout_sec: int = configs.squish.PROCESS_TIMEOUT_SEC):
    started_at = time.monotonic()
    while True:
        pid_list = get_pid(process_name)
        if pid_list:
            return pid_list
        time.sleep(1)
        assert time.monotonic() - started_at < timeout_sec, f'Start process error: {process_name}'


def wait_for_close(process_name: str, timeout_sec: int = configs.squish.PROCESS_TIMEOUT_SEC):
    started_at = time.monotonic()
    while True:
        if not get_pid(process_name):
            break
        time.sleep(1)
        assert time.monotonic() - started_at < timeout_sec, f'Close process error: {process_name}'


def execute(
        command: list,
        shell=True,
        stderr=subprocess.PIPE,
        stdout=subprocess.PIPE,
        timeout_sec=None,
        check=True
):
    command = " ".join(str(atr) for atr in command)
    run = subprocess.Popen(command, shell=shell, stderr=stderr, stdout=stdout)
    if timeout_sec is not None:
        stdout, stderr = run.communicate()
        if check and run.returncode != 0:
            raise subprocess.CalledProcessError(run.returncode, command, stdout, stderr)
        return subprocess.CompletedProcess(command, run.returncode, stdout, stderr)
    return run.pid
