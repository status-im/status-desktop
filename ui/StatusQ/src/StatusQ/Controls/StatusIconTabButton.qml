import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

TabButton {
    id: statusIconTabButton

    property string name: ""

    implicitWidth: 40
    implicitHeight: 40

    icon.height: 24
    icon.width: 24
    icon.color: Theme.palette.baseColor1

    contentItem: Item {
        anchors.fill: parent

        Loader {
            active: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: statusIconTabButton.name !== "" && !icon.source.toString() ? letterIdenticon :
              !!icon.source.toString() ? imageIcon : defaultIcon
        }

        Component {
            id: defaultIcon
            StatusIcon {
                icon: statusIconTabButton.icon.name
                height: statusIconTabButton.icon.height
                width: statusIconTabButton.icon.width
                color: (statusIconTabButton.hovered || statusIconTabButton.checked) ? Theme.palette.primaryColor1 : statusIconTabButton.icon.color
            }
        }

        Component {
            id: imageIcon
            StatusRoundedImage {
                width: 28
                height: 28
                image.source: icon.source
            }
        }

        Component {
            id: letterIdenticon
            StatusLetterIdenticon {
                width: 26
                height: 26
                letterSize: 15
                name: statusIconTabButton.name
                color: (statusIconTabButton.hovered || statusIconTabButton.checked) ? Theme.palette.primaryColor1 : statusIconTabButton.icon.color
            }
        }
    }

    background: Rectangle {
        color: hovered || ((!!icon.source.toString() || !!name) && checked) ? Theme.palette.primaryColor3 : "transparent"
        border.color: Theme.palette.primaryColor1
        border.width: (!!icon.source.toString() || !!name) && checked ? 1 : 0
        radius: statusIconTabButton.width / 2
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onPressed: mouse.accepted = false
    }
}

