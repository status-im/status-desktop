import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import shared 1.0
import utils 1.0

Item {
    id: root

    /* required */ property int filteredIndex
    /* required */ property var notification
    /* required */ property var store
    /* required */ property var activityCenterStore

    property alias bodyComponent: bodyLoader.sourceComponent
    property alias badgeComponent: badgeLoader.sourceComponent
    property alias ctaComponent: ctaLoader.sourceComponent

    signal closeActivityCenter()

    implicitHeight: Math.max(60, bodyLoader.height + bodyLoader.anchors.topMargin * 2 +
                                 (dateGroupLabel.visible ? dateGroupLabel.height : 0) +
                                 (badgeLoader.item ? badgeLoader.height + Style.current.smallPadding : 0))

    StatusDateGroupLabel {
        id: dateGroupLabel
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        messageTimestamp: notification ? notification.timestamp : 0
        previousMessageTimestamp: !notification || filteredIndex === 0 || !notification.previousTimestamp ?
                                        0 : notification.previousTimestamp
        visible: text !== ""
    }

    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        anchors.topMargin: dateGroupLabel.visible ? dateGroupLabel.height : 0
        radius: 6
        color: notification && !notification.read ? Theme.palette.primaryColor3 : "transparent"
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    Loader {
        id: bodyLoader
        anchors.top: dateGroupLabel.visible ? dateGroupLabel.bottom : parent.top
        anchors.topMargin: Style.current.smallPadding
        anchors.right: ctaLoader.left
        anchors.left: parent.left
    }

    Loader {
        id: badgeLoader
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.smallPadding
        anchors.left: parent.left
        anchors.leftMargin: 50 // TODO find a way to align with the text of the message
    }

    Loader {
        id: ctaLoader
        anchors.verticalCenter: bodyLoader.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding

        sourceComponent: StatusFlatRoundButton {
            icon.width: 20
            icon.height: 20
            icon.name: "checkmark"
            icon.color: notification && notification.read ? icon.disabledColor : Theme.palette.primaryColor1
            tooltip.text: notification && notification.read ? qsTr("Mark as Unread") : qsTr("Mark as Read")
            tooltip.orientation: StatusToolTip.Orientation.Left
            tooltip.x: -tooltip.width - Style.current.padding
            tooltip.y: 4
            onClicked: {
                notification.read ?
                    root.activityCenterStore.markActivityCenterNotificationUnread(root.notification) :
                    root.activityCenterStore.markActivityCenterNotificationRead(root.notification)
            }
        }
    }
}
