import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared 1.0
import utils 1.0
import shared.panels.chat 1.0

ActivityNotificationBase {
    id: root

    markReadBtnVisible: false
    height: 60

    StatusSmartIdenticon {
        id: identicon
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
        name: notification.author
        asset.color: Theme.palette.miscColor5
    }

    RowLayout {
        anchors.top: parent.top
        anchors.left: identicon.right

        StatusBaseText {
            text: notification.name
            font.pixelSize: 15
            color: Style.current.primary
        }

        StatusBaseText {
            text: Utils.getElidedPk(notification.author) + " \u2022"
            font.pixelSize: 12
            color: Style.current.secondaryText
        }

        ChatTimePanel {
            font.pixelSize: 12
            color: Style.current.secondaryText
            timestamp: notification.timestamp
        }
    }
}