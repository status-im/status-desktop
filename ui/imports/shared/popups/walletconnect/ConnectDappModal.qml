import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.14

import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import utils 1.0

StatusDialog {
    id: root

    width: 480
    implicitHeight: 633

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    title: qsTr("Connection request")

    function openWithFilter(chains, accounts, proposer) {
        let m = proposer.metadata
        dappCard.name = m.name
        dappCard.url = m.url
        if(m.icons.length > 0) {
            dappCard.icon = m.icons[0]
        }
        root.open()
    }

    padding: 20

    contentItem: ColumnLayout {
        spacing: 20

        DAppCard {
            id: dappCard

            Layout.alignment: Qt.AlignHCenter
            Layout.leftMargin: 12
            Layout.rightMargin: Layout.leftMargin
            Layout.topMargin: 20
            Layout.bottomMargin: Layout.topMargin
        }

        // TODO DEV the spacer should not be needed when all the content is available
        Item { Layout.fillHeight: true }
    }

    footer: StatusDialogFooter {
        id: footer
        rightButtons: ObjectModel {
            StatusButton {
                height: 44
                text: qsTr("Decline")

                onClicked: console.debug(`TODO #14607: Decline button clicked`)
            }
            StatusButton {
                height: 44
                text: qsTr("Connect")

                onClicked: console.debug(`TODO #14607: Connect button clicked`)
            }
        }
    }

    component DAppCard: ColumnLayout {
        property alias name: appNameText.text
        property alias url: appUrlText.text
        property alias icon: d.iconSource

        // TODO: this doesn't work as expected, the icon is not displayed properly
        StatusRoundIcon {
            id: iconDisplay

            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 16

            width: 72
            height: 72

            asset.source: d.iconSource
            asset.width: width
            asset.height: height
            asset.color: "transparent"
            asset.bgColor: "transparent"
        }

        StatusBaseText {
            id: appNameText

            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 4

            font.bold: true
            font.pixelSize: 17
        }

        // TODO replace with the proper URL control
        StatusLinkText {
            id: appUrlText

            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 15
        }

        QtObject {
            id: d
            property string iconSource: ""
        }
    }
}
