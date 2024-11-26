import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import shared.popups.walletconnect 1.0
import utils 1.0

ColumnLayout {
    id: root
    property alias name: appNameText.text
    property url dAppUrl: ""
    property url iconUrl: ""
    // Property specifing the icon for the connector badge
    property alias connectorBadge: dappIcon.badgeIcon
    property bool connectionSuccessful
    property bool connectionAttempted

    spacing: Theme.padding

    RoundImageWithBadge {
        id: dappIcon
        objectName: "dappIcon"
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 72
        Layout.preferredHeight: Layout.preferredWidth
        badgeSize: 20
        badgeMargin: 1

        imageUrl: iconUrl
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4

        StatusBaseText {
            id: appNameText
            objectName: "appNameText"
            Layout.fillWidth: true
            Layout.maximumWidth: root.width
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            font.bold: true
            font.pixelSize: 17
        }

        StatusFlatButton {
            id: appUrlText
            objectName: "appUrlControl"
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: root.width
            icon.name: "external-link"
            icon.color: hovered ? Theme.palette.baseColor1 : Theme.palette.directColor1
            textPosition: StatusBaseButton.TextPosition.Left
            size: StatusBaseButton.Size.Tiny
            textColor: Theme.palette.directColor1
            hoverColor: "transparent"
            spacing: 0
            font.pixelSize: 15
            font.weight: Font.Normal
            horizontalPadding: 0
            verticalPadding: 0
            text: StringUtils.extractDomainFromLink(dAppUrl)
            onClicked: {
                Global.openLinkWithConfirmation(dAppUrl, text)
            }
        }
        ConnectionStatusTag {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: root.width
            objectName: "connectionStatusTag"
            success: root.connectionSuccessful
            visible: root.connectionAttempted
        }
    }
}
