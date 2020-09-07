import QtQml 2.13

Timer {
    id: timerEstimateGas
    interval: 600
    function startOrRestartIfRunning() {
        if (running) return restart()
        start()
    }
}