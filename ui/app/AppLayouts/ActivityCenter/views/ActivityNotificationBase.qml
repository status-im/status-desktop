import QtQuick

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Controls

import shared
import utils

import AppLayouts.Chat.stores as ChatStores

import AppLayouts.ActivityCenter.stores

Item {
    id: root

    /* required */ property int filteredIndex
    /* required */ property var notification
    /* required */ property ActivityCenterStore activityCenterStore

    property alias bodyComponent: bodyLoader.sourceComponent
    property alias badgeComponent: badgeLoader.sourceComponent
    property alias ctaComponent: ctaLoader.sourceComponent

    signal closeActivityCenter()

    implicitHeight: Math.max(60, bodyLoader.height + bodyLoader.anchors.topMargin * 2 +
                                 (dateGroupLabel.visible ? dateGroupLabel.height : 0) +
                                 (badgeLoader.item ? badgeLoader.height + Theme.smallPadding : 0))

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
        anchors.topMargin: Theme.smallPadding
        anchors.right: ctaLoader.left
        anchors.rightMargin: Theme.smallPadding
        anchors.left: parent.left
        clip: true
    }

    Loader {
        id: badgeLoader
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.smallPadding
        anchors.left: parent.left
        anchors.leftMargin: 50 // TODO find a way to align with the text of the message
    }

    Loader {
        id: ctaLoader
        anchors.verticalCenter: bodyLoader.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding

        sourceComponent: StatusFlatRoundButton {
            icon.width: 20
            icon.height: 20
            icon.name: "checkmark"
            icon.color: notification && notification.read ? icon.disabledColor : Theme.palette.primaryColor1
            tooltip.text: notification && notification.read ? qsTr("Mark as Unread") : qsTr("Mark as Read")
            tooltip.orientation: StatusToolTip.Orientation.Left
            tooltip.x: -tooltip.width - Theme.padding
            tooltip.y: 4
            onClicked: {
                notification.read ?
                    root.activityCenterStore.markActivityCenterNotificationUnread(root.notification) :
                    root.activityCenterStore.markActivityCenterNotificationRead(root.notification)
            }
        }
    }
}
