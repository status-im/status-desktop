import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Communities.panels 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            anchors.fill: holdersPanel

            color: "transparent"
            border.color: "lightgray"
            anchors.margins: -1
        }

        SortableTokenHoldersPanel {
            id: holdersPanel

            anchors.centerIn: parent
            width: 568
            tokenName: "Aniversary"

            TokenHoldersModel {
                id: tokenHoldersModel
            }

            ListModel {
                id: emptyModel
            }

            model: emptyCheckBox.checked ? emptyModel : tokenHoldersModel
            showRemotelyDestructMenuItem: remotelyDestructCheckBox.checked
            isAirdropEnabled: airdropCheckBox.checked

            onViewProfileRequested:
                logs.logEvent("onViewProfileRequested: " + contactId)
            onViewMessagesRequested:
                logs.logEvent("onViewMessagesRequested: " + contactId)
            onAirdropRequested:
                logs.logEvent("onAirdropRequested: " + address)
            onRemoteDestructRequested:
                logs.logEvent("onRemoteDestructRequested: " + address)
            onKickRequested:
                logs.logEvent("onKickRequested: " + address)
            onBanRequested:
                logs.logEvent("onBanRequested: " + address)
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        ColumnLayout {
            CheckBox {
                id: emptyCheckBox

                text: "Empty"
            }
            CheckBox {
                id: remotelyDestructCheckBox

                checked: true
                text: "Show \"Remotely Destruct\"  menu item"
            }
            CheckBox {
                id: airdropCheckBox

                text: "Airdrop enabled"
                checked: true
            }
        }
    }
}

// category: Panels

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?type=design&node-id=29566-690307&mode=design&t=xJYwzqj8f8v72gYz-0
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?type=design&node-id=29566-690334&mode=design&t=xJYwzqj8f8v72gYz-0
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?type=design&node-id=29566-690939&mode=design&t=xJYwzqj8f8v72gYz-0
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?type=design&node-id=29566-690557&mode=design&t=xJYwzqj8f8v72gYz-0
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?type=design&node-id=29566-691130&mode=design&t=xJYwzqj8f8v72gYz-0
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?type=design&node-id=29566-691320&mode=design&t=xJYwzqj8f8v72gYz-0
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?type=design&node-id=29566-691513&mode=design&t=xJYwzqj8f8v72gYz-0
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?type=design&node-id=29566-691703&mode=design&t=xJYwzqj8f8v72gYz-0
