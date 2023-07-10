import QtQuick 2.15

import StatusQ.Controls 0.1

Item {
    id: root
    property string aliasedObjectName
    property string text
    property string icon
    property alias tooltipText: tooltip.text
    property int buttonType: DisabledTooltipButton.Normal
    property bool interactive: true
    signal clicked()

    enum Type {
        Normal, // 0
        Flat // 1
    }

    implicitWidth: !!buttonLoader.item ? buttonLoader.item.width : 0
    implicitHeight: !!buttonLoader.item ? buttonLoader.item.height : 0

    Loader {
        id: buttonLoader
        anchors.centerIn: parent
        sourceComponent: buttonType === DisabledTooltipButton.Normal ? normalButton : flatButton
        active: root.visible
    }
    HoverHandler {
        id: hoverHandler
        enabled: !root.interactive
        cursorShape: Qt.PointingHandCursor
    }
    StatusToolTip {
        id: tooltip
        visible: hoverHandler.hovered
    }

    Component{
        id: flatButton
        StatusFlatButton {
            objectName: root.aliasedObjectName
            icon.name: root.icon
            text: root.text
            enabled: root.interactive
            onClicked: root.clicked()
        }
    }
    Component{
        id: normalButton
        StatusButton {
            objectName: root.aliasedObjectName
            icon.name: root.icon
            text: root.text
            enabled: root.interactive
            onClicked: root.clicked()
        }
    }
}
