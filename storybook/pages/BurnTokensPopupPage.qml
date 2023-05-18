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

            BurnTokensPopup {
                id: dialog

                anchors.centerIn: parent
                communityName: editorCommunity.text
                tokenName: editorToken.text
                remainingTokens: editorAmount.text
                isAsset: assetButton.checked
                tokenSource: assetButton.checked ? ModelsData.assets.socks :  ModelsData.collectibles.kitty1Big

                onBurnClicked: logs.logEvent("BurnTokensPopup::onBurnClicked --> Burn amount: " + burnAmount)
                onCancelClicked: logs.logEvent("BurnTokensPopup::onCancelClicked")
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
                text: "Community name:"
            }

            TextField {
                id: editorCommunity
                background: Rectangle { border.color: 'lightgrey' }
                Layout.preferredWidth: 200
                text: "Community lovers"
            }

            Label {
                Layout.fillWidth: true
                Layout.topMargin: 16

                text: "Token name:"
            }

            TextField {
                id: editorToken
                background: Rectangle { border.color: 'lightgrey' }
                Layout.preferredWidth: 200
                text: "Anniversary"
            }

            Label {
                Layout.fillWidth: true
                Layout.topMargin: 16

                text: "Amount to burn:"
            }

            TextField {
                id: editorAmount
                background: Rectangle { border.color: 'lightgrey' }
                Layout.preferredWidth: 200
                text: "123"
            }

            Label {
                Layout.fillWidth: true
                Layout.topMargin: 16

                text: "Token source:"
            }

            RadioButton {
                id: assetButton

                text: "Asset"
                checked: true
            }

            RadioButton {
                id: collectibleButton

                text: "Collectible"
            }
        }
    }
}


