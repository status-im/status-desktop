import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Controls

import shared
import utils

import AppLayouts.Chat.stores as ChatStores

Control {
    id: root

    required property var notification

    property alias avatarComponent: avatarLoader.sourceComponent
    property alias bodyComponent: bodyLoader.sourceComponent
    property alias badgeComponent: badgeLoader.sourceComponent
    property alias ctaComponent: ctaLoader.sourceComponent

    property alias backgroundColor: backgroundItem.color

    signal closeActivityCenter() // TODO: to be removed
    signal markActivityCenterNotificationReadRequested(string notificationId) // TODO: to be removed
    signal markActivityCenterNotificationUnreadRequested(string notificationId) // TODO: to be removed

    implicitWidth: 308

    background: Rectangle {
        id: backgroundItem
        radius: 6
        color: root.hovered ? Theme.palette.primaryColor3 : StatusColors.transparent

        Behavior on color { ColorAnimation { duration: 200 } }

        StatusBadge {
            id: readBadge
            visible: notification ? !notification.read : false
            height: 8
            width: height
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: Theme.halfPadding
            anchors.topMargin: Theme.halfPadding
        }
    }

    contentItem: RowLayout {
        spacing: Theme.halfPadding
        width: parent.width

        Loader {
            id: avatarLoader
            Layout.topMargin: Theme.padding
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: Theme.padding
        }

        ColumnLayout {
            Layout.fillWidth: true

            Loader {
                id: bodyLoader
                Layout.topMargin: Theme.padding
                Layout.rightMargin: Theme.padding
                Layout.fillWidth: true
            }

            Loader {
                id: badgeLoader
                Layout.maximumWidth: parent.width - Theme.padding
            }

            StatusTimeStampLabel {
                Layout.bottomMargin: ctaLoader.active ? 0 : Theme.smallPadding
                timestamp: root.notification?.timestamp ?? 0
            }

            Loader {
                id: ctaLoader
                Layout.topMargin: ctaLoader.active ? Theme.halfPadding : 0
                Layout.bottomMargin: Theme.smallPadding
            }
        }
    }
}
