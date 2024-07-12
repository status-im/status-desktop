// Subset of https://github.com/e-fever/backpressure, refactored to modern JS

pragma Singleton

import QtQml 2.15

QtObject {
    id: root

    property var _timers: ({})
    property int _nextId: 0

    function setTimeout(owner, timeout, callback) {
        const tid = ++_nextId

        const cleanup = () => {
            if (!!tid)
                clearTimeout(tid)
        }

        if (!owner)
            owner = root

        owner.Component.onDestruction.connect(cleanup)

        const obj = Qt.createQmlObject(
                    'import QtQuick 2.15; Timer { '
                    + 'running: false; repeat: false; '
                    + `interval: ${timeout}}`,
                    root, "setTimeout")

        obj.triggered.connect(() => {
            callback()
            obj.destroy()
            owner.Component.onDestruction.disconnect(cleanup)
            delete _timers[tid]
        })

        obj.running = true
        _timers[tid] = obj

        return tid
    }

    function clearTimeout(timerId) {
        if (!_timers.hasOwnProperty(timerId))
            return

        const timer = _timers[timerId]
        timer.stop()
        timer.destroy()
        delete _timers[timerId]
    }

    function oneInTime(owner, duration, callback) {
        let pending = false
        let timerId = null

        return function() {
            if (pending)
                return

            pending = true
            const args = arguments
            callback.apply(null, args)
            timerId = setTimeout(owner, duration , () => {
                pending = false
            }, duration)
        }
    }

    // Same as `oneInTime` while also handling any queued calls
    function oneInTimeQueued(owner, duration, callback) {
        let pending = false
        let queued = false
        let timerId = null

        const proxy = () => {
            if (pending) {
                queued = true
                return
            }
            pending = true
            queued = false
            const args = arguments
            callback.apply(null, args)
            timerId = setTimeout(owner, duration , () => {
                pending = false
                if (queued)
                    proxy(owner, duration, callback)
            }, duration)
        }

        return proxy
    }

    function debounce(owner, duration, callback) {
        let timerId = null

        return function() {
            const args = arguments

            if (timerId !== null)
                clearTimeout(timerId)

            timerId = setTimeout(owner, duration, function() {
                timerId = null
                callback.apply(null, args)
            })
        }
    }
}
