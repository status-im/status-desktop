import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import shared 1.0
import utils 1.0

Item {
    id: root

    property var notification
    property var store
    property var activityCenterStore

    property alias bodyComponent: bodyLoader.sourceComponent
    property alias badgeComponent: badgeLoader.sourceComponent
    property alias ctaComponent: ctaLoader.sourceComponent
    property alias previousNotificationIndex: dateGroupLabel.previousMessageIndex

    signal closeActivityCenter()

    implicitHeight: Math.max(60, bodyLoader.height +
                                 (dateGroupLabel.visible ? dateGroupLabel.height : 0) +
                                 (badgeLoader.item ? badgeLoader.height + Style.current.smallPadding : 0))

    StatusDateGroupLabel {
        id: dateGroupLabel
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        messageTimestamp: notification.timestamp
        previousMessageTimestamp: root.activityCenterStore.activityCenterList.getNotificationData(
                                    previousNotificationIndex, "timestamp")
        visible: text !== ""
    }

    Loader {
        id: bodyLoader
        anchors.top: dateGroupLabel.visible ? dateGroupLabel.bottom : parent.top
        anchors.right: ctaLoader.left
        anchors.left: parent.left
    }

    Loader {
        id: badgeLoader
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 50 // TODO find a way to align with the text of the message
    }

    Loader {
        id: ctaLoader
        anchors.verticalCenter: bodyLoader.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding

        sourceComponent: StatusFlatRoundButton {
            id: markReadBtn
            icon.width: 20
            icon.height: 20
            icon.source: Style.svg("check-activity")
            icon.color: root.notification.read ? icon.disabledColor : "transparent"
            tooltip.text: !root.notification.read ? qsTr("Mark as Read") : qsTr("Mark as Unread")
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