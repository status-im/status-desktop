import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Communities.panels 1.0
import AppLayouts.Chat.stores 1.0
import StatusQ.Core.Theme 0.1

import Storybook 1.0
import Models 1.0


SplitView {
    orientation: Qt.Vertical
    SplitView.fillWidth: true

    Logs { id: logs }

    ListModel {
        id: emptyModel
    }

    Button {
        text: "Back"
        onClicked: panel.navigateBack()
    }
    Rectangle {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        color: Theme.palette.statusAppLayout.rightPanelBackgroundColor        

        MintTokensSettingsPanel {
            id: panel

            anchors.fill: parent
            anchors.topMargin: 50
            tokensModel: editorModelChecked.checked ? emptyModel : MintedTokensModel.mintedTokensModel
            layer1Networks: NetworksModel.layer1Networks
            layer2Networks: NetworksModel.layer2Networks
            testNetworks: NetworksModel.testNetworks
            enabledNetworks: NetworksModel.enabledNetworks
            allNetworks: enabledNetworks
            accounts: WalletAccountsModel {}

            onMintCollectible: logs.logEvent("CommunityMintTokensSettingsPanel::mintCollectible")
            onMintAsset: logs.logEvent("CommunityMintTokensSettingsPanel::mintAssets")
            onDeleteToken: logs.logEvent("CommunityMintTokensSettingsPanel::deleteToken: " + tokenKey)
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 150

        logsView.logText: logs.logText

        RowLayout {
            ColumnLayout {
                Label {
                    Layout.fillWidth: true
                    text: "Is empty model?"
                }

                CheckBox {
                    id: editorModelChecked
                    checked: true
                }
            }
            ColumnLayout {
                Label {
                    Layout.fillWidth: true
                    text: "Is minting in progress?"
                }

                CheckBox {
                    id: editorMintingChecked
                    checked: true
                    onCheckedChanged:{
                        if(checked)
                            MintedTokensModel.changeAllMintingStates(1/*In progress*/)
                        else
                            MintedTokensModel.changeAllMintingStates(2/*Deployed*/)
                    }

                }
            }
        }
    }
}
