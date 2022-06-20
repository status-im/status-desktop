import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import StatusQ.Components 0.1
import utils 1.0
import shared.stores 1.0

Item {
    id: root
    property bool isPending: false
    readonly property string uuid: Utils.uuid()
    property int debounceDelay: 600

    readonly property var validateAsync: Backpressure.debounce(inpAddress, debounceDelay, function (inputValue) {
        root.isPending = true
        var name = inputValue.startsWith("@") ? inputValue.substring(1) : inputValue
        mainModule.resolveENS(name, uuid)
    });
    signal resolved(string resolvedAddress)

    function resolveEns(name) {
        if (Utils.isValidEns(name)) {
            root.validateAsync(name)
        }
    }
    width: Style.dp(12)
    height: Style.dp(12)

    Loader {
        anchors.fill: parent
        sourceComponent: loadingIndicator
        active: root.isPending
    }

    Component {
        id: loadingIndicator
        StatusLoadingIndicator {
            width: root.width
            height: root.height
        }
    }

    Connections {
        target: mainModule
        onResolvedENS: {
            if (uuid !== root.uuid) {
                return
            }
            root.isPending = false
            root.resolved(resolvedAddress)
        }
    }
}
