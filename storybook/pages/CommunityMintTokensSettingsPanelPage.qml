import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Chat.panels.communities 1.0
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

    Rectangle {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        color: Theme.palette.statusAppLayout.rightPanelBackgroundColor

        CommunityMintTokensSettingsPanel {
            anchors.fill: parent
            anchors.topMargin: 50
            tokensModel: editorModelChecked.checked ? emptyModel : MintedCollectiblesModel.mintedCollectibleModel
            holdersModel: TokenHoldersModel {}
            layer1Networks: NetworksModel.layer1Networks
            layer2Networks: NetworksModel.layer2Networks
            testNetworks: NetworksModel.testNetworks
            enabledNetworks: NetworksModel.enabledNetworks
            allNetworks: enabledNetworks
            accounts: WalletAccountsModel {}

            onMintCollectible: logs.logEvent("CommunityMintTokensSettingsPanel::mintCollectible")
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
                            MintedCollectiblesModel.changeAllMintingStates(1/*In progress*/)
                        else
                            MintedCollectiblesModel.changeAllMintingStates(2/*Deployed*/)
                    }

                }
            }
        }
    }
}
