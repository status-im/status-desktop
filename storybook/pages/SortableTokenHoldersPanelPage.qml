import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Chat.panels.communities 1.0

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

            onViewProfileRequested:
                logs.logEvent("onViewProfileRequested: " + address)
            onViewMessagesRequested:
                logs.logEvent("onViewMessagesRequested: " + address)
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
        }
    }
}
