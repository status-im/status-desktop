import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0

import AppLayouts.Chat.popups.community 1.0

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            PopupBackground {
                anchors.fill: parent
            }

            Button {
                anchors.centerIn: parent
                text: "Reopen"

                onClicked: dialog.open()
            }

            SignTokenTransactionsPopup {
                id: dialog

                anchors.centerIn: parent
                title: qsTr("Sign transaction - Self-destruct %1 tokens").arg(dialog.tokenName)
                accountName: editorAccount.text
                tokenName: editorCollectible.text
                networkName: editorNetwork.text
                feeText: editorFee.text
                isFeeLoading: editorFeeLoader.checked

                onSignTransactionClicked: logs.logEvent("SignTokenTransactionsPopup::onSignTransactionClicked")
                onCancelClicked: logs.logEvent("SignTokenTransactionsPopup::onCancelClicked")

            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {

            Label {
                Layout.fillWidth: true
                text: "Account name"
            }

            TextField {
                id: editorAccount
                background: Rectangle { border.color: 'lightgrey' }
                Layout.preferredWidth: 200
                text: "helloworld"
            }

            Label {
                Layout.fillWidth: true
                text: "Collectible name"
            }

            TextField {
                id: editorCollectible
                background: Rectangle { border.color: 'lightgrey' }
                Layout.preferredWidth: 200
                text: "Anniversary"
            }

            Label {
                Layout.fillWidth: true
                text: "Network name"
            }

            TextField {
                id: editorNetwork
                background: Rectangle { border.color: 'lightgrey' }
                Layout.preferredWidth: 200
                text: "Optimism"
            }

            Label {
                Layout.fillWidth: true
                text: "Network name"
            }

            TextField {
                id: editorFee
                background: Rectangle { border.color: 'lightgrey' }
                Layout.preferredWidth: 200
                text: "0.0015 ETH ($75.34)"
            }

            Switch {
                id: editorFeeLoader
                text: "Is fee loading?"
                checked: false
            }
        }
    }
}


