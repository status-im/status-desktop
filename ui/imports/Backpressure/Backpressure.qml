pragma Singleton
import QtQuick 2.0

Item {

    id: backpressure

    property var _timers: ({})
    property int _nextId: 0

    function setTimeout(owner, timeout, callback) {
        var tid = ++_nextId;

        var cleanup = function() {
            if (tid !== null) {
                clearTimeout(tid);
            }
        }

        if (!owner) {
            owner = backpressure;
        }

        owner.Component.onDestruction.connect(cleanup);

        var obj = Qt.createQmlObject('import QtQuick 2.0; Timer {running: false; repeat: false; interval: ' + timeout + '}', backpressure, "setTimeout");
        obj.triggered.connect(function() {
            callback();
            obj.destroy();
            owner.Component.onDestruction.disconnect(cleanup);
            delete _timers[tid];
        });
        obj.running = true;
        _timers[tid] = obj;
        return tid;
    }

    function clearTimeout(timerId) {
        if (!_timers.hasOwnProperty(timerId)) {
            return;
        }
        var timer = _timers[timerId];
        timer.stop();
        timer.destroy();
        delete _timers[timerId];
    }

    function oneInTime(owner, duration, callback) {
        var pending = false;
        var timerId = null;

        return function() {
            if (pending) {
                return;
            }
            pending = true;
            var args = arguments;
            callback.apply(null, args);
            timerId = setTimeout(owner, duration , function() {
                pending = false;
            }, duration);
        }
    }

    function promisedOneInTime(owner, callback) {
        var q = priv.loadPromiseLib();
        var promise = null;

        return function() {
            var args = arguments;
            if (promise !== null) {
                return q.rejected();
            }

            promise = q.promise(function(fulfill, reject) {
                fulfill(callback.apply(null, args));
            });

            promise.then(function() {
                promise = null;
            }, function() {
                promise = null;
            });
            return promise;
        };
    }

    function debounce(owner, duration, callback) {
        var timerId = null;

        return function() {
            var args = arguments;

            if (timerId !== null) {
                clearTimeout(timerId);
            }

            timerId = setTimeout(owner, duration, function() {
                timerId = null;
                callback.apply(null, args);
            });
        }
    }    

    QtObject {
        id: priv
        property var q: null

        function loadPromiseLib() {
            if (q !== null) {
                return q.q;
            }

            q = Qt.createQmlObject('import QtQuick 2.0; import QuickPromise 1.0; Item { property var q: Q;}', backpressure);
            if (q.hasOwnProperty("qmlErrors")) {
                console.error("Backpressure: Failed to load QuickPromise. Please check your installation.");
            }
            return q.q;
        }

    }

}
