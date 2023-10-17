import QtQuick 2.14
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

Switch {
    id: root

    property color textColor: Theme.palette.directColor1

    background: MouseArea {
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.NoButton
    }

    indicator: Item {
        id: oval

        implicitWidth: 52
        implicitHeight: 28
        anchors.left: parent.left
        anchors.leftMargin: root.leftPadding
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            anchors.fill: parent

            radius: 14
            color: root.checked ? Theme.palette.primaryColor1
                                : Theme.palette.directColor8
            opacity: root.enabled ? 1 : 0.2
        }

        Rectangle {
            id: circle
            y: 4
            width: 20
            height: 20
            radius: 10
            color: Theme.palette.white
            layer.enabled: true
            layer.effect: DropShadow {
                width: parent.width
                height: parent.height
                visible: true
                verticalOffset: 1
                fast: true
                cached: true
                color: Theme.palette.dropShadow
            }

            states: [
                State {
                    name: "on"
                    when: root.checked
                    PropertyChanges { target: circle; x: oval.width - circle.width - 4 }
                },
                State {
                    name: "off"
                    when: !root.checked
                    PropertyChanges { target: circle; x: 4 }
                }
            ]

            transitions: Transition {
                reversible: true
                NumberAnimation { properties: "x"; easing.type: Easing.Linear; duration: 120}
            }
        }
    }

    contentItem: StatusBaseText {
        text: root.text
        opacity: enabled ? 1.0 : 0.3
        color: root.textColor
        verticalAlignment: Text.AlignVCenter
        leftPadding: root.mirrored ? 0 : !!root.text ? root.indicator.width + root.spacing : root.indicator.width
        rightPadding: root.mirrored ? !!root.text ? root.indicator.width + root.spacing : root.indicator.width : 0
    }
}
