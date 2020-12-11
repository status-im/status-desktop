import QtQuick 2.13
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.13
import "./" as MessageComponents
import "../../../../../imports"
import "../../../../../shared"

Item {
    id: root
    default property alias inner: contents.children
    property bool isCurrentUser: false
    readonly property int smallCorner: Style.current.radius / 2
    readonly property int bigCorner: Style.current.radius * 2
    readonly property int fakeCornerSize: bigCorner * 2

    Rectangle {
        width: parent.width + 2
        height: parent.height + 2
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: -1
        anchors.leftMargin: -1
        radius: root.bigCorner
        border.width: 2
        border.color: Style.current.border
    }
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: -1
        anchors.leftMargin: -1
        width: root.fakeCornerSize
        height: root.fakeCornerSize
        radius: root.smallCorner
        visible: !root.isCurrentUser
        border.width: 2
        border.color: Style.current.border
    }
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: -1
        anchors.rightMargin: -1
        width: root.fakeCornerSize
        height: root.fakeCornerSize
        radius: root.smallCorner
        visible: root.isCurrentUser
        border.width: 2
        border.color: Style.current.border
    }

    Rectangle {
        anchors.fill: parent
        color: Style.current.background

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Item {
                width: root.width
                height: root.height

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    width: parent.width
                    height: parent.height
                    radius: root.bigCorner
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    width: root.fakeCornerSize
                    height: root.fakeCornerSize
                    radius: root.smallCorner
                    visible: !root.isCurrentUser
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: root.fakeCornerSize
                    height: root.fakeCornerSize
                    radius: root.smallCorner
                    visible: root.isCurrentUser
                }
            }
        }

        Item {
            id: contents
            width: root.width
            height: root.height
        }
    }
}