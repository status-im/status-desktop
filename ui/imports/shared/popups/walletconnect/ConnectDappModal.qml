import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.14

import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Controls 0.1

import utils 1.0

import "ConnectDappModal"

StatusDialog {
    id: root

    signal pair(string uri)

    width: 480
    implicitHeight: 633

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    title: qsTr("Connect a dApp via WalletConnect")

    padding: 20

    contentItem: ColumnLayout {
        StatusBaseText {
            text: "WalletConnect URI"
        }

        WCUriInput {
            id: uriInput
        }

        // Spacer
        ColumnLayout {}

        StatusLinkText {
            text: qsTr("How to copy the dApp URI")

            Layout.alignment: Qt.AlignHCenter
            Layout.margins: 18

            normalColor: linkColor

            onClicked: {
                console.warn("TODO: open help...")
            }
        }
    }

    footer: StatusDialogFooter {
        id: footer
        rightButtons: ObjectModel {
            StatusButton {
                height: 44
                text: qsTr("Done")

                enabled: uriInput.valid && uriInput.text.length > 0

                onClicked: root.pair(uriInput.text)
            }
        }
    }
}
