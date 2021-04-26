import QtQuick 2.13
import QtQuick.Controls 2.13
Item {
    id: __impl

    readonly property real minFactor: 0.5
    readonly property real maxFacctor: 2.0
    property real factor: 1.0

    Action {
        shortcut: "CTRL+="
        onTriggered: {
            if (factor < __impl.maxFacctor) {
                factor += 0.1
            }
        }
    }

    Action {
        shortcut: "CTRL+-"
        onTriggered: {
            if (factor > __impl.minFactor) {
                factor -= 0.1
            }
        }
    }

    Action {
        shortcut: "CTRL+0"
        onTriggered: {
            factor = 1.0
        }
    }

}
