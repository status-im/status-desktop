import QtQuick 2.13
import QtGraphicalEffects 1.0
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    property bool showLoadingIndicator: false

    property bool isLoading: false
    property bool isError: false

    implicitWidth: 40
    implicitHeight: 40
    color: "transparent"
    radius: width / 2
    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            x: root.x; y: root.y
            width: root.width
            height: root.height
            radius: root.radius
        }
    }

    Loader {
        id: itemSelector
        anchors.centerIn: parent
        active: showLoadingIndicator && !isError && isLoading
        sourceComponent: StatusLoadingIndicator {
            color: Theme.palette.directColor6
        }
    }
}
