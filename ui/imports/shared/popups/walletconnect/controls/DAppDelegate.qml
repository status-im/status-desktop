import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import shared.popups.walletconnect 1.0

MouseArea {
    id: root
    implicitHeight: 50

    hoverEnabled: true

    required property string name
    required property url url
    required property url iconUrl
    required property url connectorBadge

    signal disconnectDapp(string dappUrl)

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8

        Item {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40

            RoundImageWithBadge {
                id: iconImage

                anchors.fill: parent

                imageUrl: root.iconUrl
                badgeIcon: root.connectorBadge
                badgeSize: 14
                badgeMargin: 2
            }
        }

        ColumnLayout {
            Layout.leftMargin: 12
            Layout.rightMargin: 12

            StatusBaseText {
                id: dAppCaption

                text: root.name ? root.name : SQUtils.StringUtils.extractDomainFromLink(root.url)

                Layout.fillWidth: true

                font.pixelSize: 13
                font.bold: true

                elide: Text.ElideRight

                clip: true
            }
            StatusBaseText {
                text: root.url

                Layout.fillWidth: true

                font.pixelSize: 12
                color: Theme.palette.baseColor1

                elide: Text.ElideRight

                clip: true
            }
        }

        StatusFlatButton {
            size: StatusBaseButton.Size.Large

            asset.color: root.containsMouse ? Theme.palette.directColor1
                                            : Theme.palette.baseColor1

            icon.name: "disconnect"
            tooltip.text: qsTr("Disconnect dApp")

            onClicked: {
                root.disconnectDapp(root.url)
            }
        }
    }
}
