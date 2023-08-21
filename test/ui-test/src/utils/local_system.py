import os
import signal
import subprocess


def kill_process(pid):
    os.kill(pid, signal.SIGKILL)


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
