import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Controls

import shared
import shared.panels
import utils

import "../controls"
import "../panels"

import AppLayouts.ActivityCenter.helpers

ActivityNotificationMessage {
    id: root

    required property var group

    signal acceptActivityCenterNotificationRequested(string notificationId)
    signal dismissActivityCenterNotificationRequested(string notificationId)

    QtObject {
        id: d

        readonly property bool pending: !accepted && ! declined
        readonly property bool accepted: notification.accepted
        readonly property bool declined: notification.dismissed

        property color stateColorText: {
            if (d.accepted) {
                return Theme.palette.successColor1
            }
            if (d.declined) {
                return Theme.palette.dangerColor1
            }
            return Theme.palette.baseColor1
        }
        property string stateText: {
            if (d.accepted) {
                return qsTr("accepted")
            }
            if (d.declined) {
                return qsTr("declined")
            }
            return ""
        }
    }

    messageDetails.messageText: qsTr("Invitation to an unknown group <font color='%1'>%2</font>").arg(d.stateColorText).arg(d.stateText)

    badgeComponent: ChannelBadge {
        chatType: notification.chatType
        name: notification.name
        asset.isImage: asset.name != ""
        asset.name: group.icon
        asset.emoji: group.emoji
        asset.color: group.color
        clip: true
    }

    ctaComponent: d.pending ? ctaPendingComponent : undefined

    Component {
        id: ctaPendingComponent

        RowLayout {
            spacing: Theme.halfPadding
            StatusFlatButton {
                icon.name: "checkmark-circle"
                icon.color: Theme.palette.successColor1
                onClicked: root.acceptActivityCenterNotificationRequested(notification.id)
                font.pixelSize: Theme.additionalTextSize
                verticalPadding: 4
                horizontalPadding: 4
            }

            StatusFlatButton {
                icon.name: "close-circle"
                icon.color: Theme.palette.dangerColor1
                onClicked: root.dismissActivityCenterNotificationRequested(notification.id)
                font.pixelSize: Theme.additionalTextSize
                verticalPadding: 4
                horizontalPadding: 4
            }
        }
    }
}
