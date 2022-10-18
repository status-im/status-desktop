import QtQuick 2.14

QtObject {
    readonly property alias logText: d.logText

    function logEvent(name, argumentNames, args) {
        d.logText += d.createLog(name, argumentNames, args) + "\n"
    }

    readonly property QtObject _d: QtObject {
        id: d

        property string logText: ""

        function createLog(name, argumentNames, args) {
            let log = (new Date()).toLocaleTimeString(Qt.locale(), "h:mm:ss") + ": " + name

            if (!args || args.length === 0)
                return log

            log += ": ["

            for (let i = 0; i < args.length; i++) {

                const argName = argumentNames[i]

                if (!!argName)
                    log +=argName + ": "

                log += JSON.stringify(args[i])

                if (i !== args.length - 1)
                    log += ", "
            }

            log += "]"

            return log
        }
    }
}
