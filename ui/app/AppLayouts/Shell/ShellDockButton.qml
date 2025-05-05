import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

TabButton {
    id: root
    
    /*required */property int sectionType // cf Constants.appSection.*
    property string tooltipText: Utils.translatedSectionName(sectionType, "")
    property bool hasNotification
    property int notificationsCount
    
    implicitWidth: 64
    implicitHeight: 64

    padding: Theme.smallPadding
    opacity: pressed || down ? Theme.pressedOpacity : enabled ? 1 : Theme.disabledOpacity
    Behavior on opacity { NumberAnimation { duration: Theme.AnimationDuration.Fast } }
    
    icon.width: 32
    icon.height: 32
    icon.color: Theme.palette.white
    
    HoverHandler {
        cursorShape: hovered ? Qt.PointingHandCursor : undefined
    }
    
    background: Rectangle {
        color: Qt.rgba(1, 1, 1, hovered ? 0.1 : 0.05) // FIXME get rid of opacity tricks
        Behavior on color { ColorAnimation { duration: Theme.AnimationDuration.Fast } }
        radius: Theme.smallPadding * 2

        // top right corner
        StatusBadge {
            width: root.notificationsCount ? implicitWidth : 12 + border.width // bigger dot
            height: root.notificationsCount ? implicitHeight : 12 + border.width
            color: hovered ? Qt.lighter(Theme.palette.primaryColor1, 1.25) : Theme.palette.primaryColor1
            Behavior on color { ColorAnimation { duration: Theme.AnimationDuration.Fast } }
            border.width: 2
            border.color: "#161d27"
            anchors.right: parent.right
            anchors.rightMargin: root.notificationsCount ? -2 : 0
            anchors.top: parent.top
            anchors.topMargin: root.notificationsCount ? -2 : 0
            visible: root.hasNotification
            value: root.notificationsCount
            radius: root.notificationsCount ? 6 : height/2
        }
    }
    
    contentItem: Item {
        StatusIcon {
            anchors.centerIn: parent
            width: root.icon.width
            height: root.icon.height
            icon: root.icon.name
            color: root.icon.color
        }
    }
    
    StatusToolTip {
        visible: !!text && root.hovered
        offset: -(x + width/2 - root.width/2)
        color: "#222833"
        text: root.tooltipText
    }
}
