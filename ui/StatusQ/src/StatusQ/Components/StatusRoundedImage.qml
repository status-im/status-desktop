import QtQuick 2.13
import QtGraphicalEffects 1.0
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    property bool showLoadingIndicator: false

    property alias image: image

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

    Image {
        id: image

        width: root.width
        height: root.height
        fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent

        onSourceChanged: {
            if (sourceSize.width < width || sourceSize.height < height) {
                sourceSize = Qt.binding(() => Qt.size(width * 2, height * 2))
            } else {
                sourceSize = undefined
            }
        }
    }

    Loader {
        id: itemSelector

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        active: showLoadingIndicator && image.status === Image.Loading

        sourceComponent: StatusLoadingIndicator {
            color: Theme.palette.directColor6
        }
    }
}
