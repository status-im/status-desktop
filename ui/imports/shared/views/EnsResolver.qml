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
    property var ensModule

    readonly property var validateAsync: Backpressure.debounce(inpAddress, debounceDelay, function (inputValue) {
        root.isPending = true
        var name = inputValue.startsWith("@") ? inputValue.substring(1) : inputValue
        root.ensModule.resolveENSWithUUID(name, uuid)
    });
    signal resolved(string resolvedAddress)

    function resolveEns(name) {
        if (Utils.isValidEns(name)) {
            root.validateAsync(name)
        }
    }
    width: 12
    height: 12

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
        enabled: !!root.ensModule
        target: root.ensModule
        onResolvedENSWithUUID: {
            if (uuid !== root.uuid) {
                return
            }
            root.isPending = false
            root.resolved(resolvedAddress)
        }
    }
}
