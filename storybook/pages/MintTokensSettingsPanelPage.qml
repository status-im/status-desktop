import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Communities.panels 1.0
import AppLayouts.Chat.stores 1.0
import StatusQ.Core.Theme 0.1

import SortFilterProxyModel 0.2

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

    Timer {
        id: feesTimer

        interval: 1000

        onTriggered: {
            panel.isFeeLoading = false
            panel.feeText = "0,0002 ETH (123,15 USD)"
        }
    }

    Rectangle {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        color: Theme.palette.statusAppLayout.rightPanelBackgroundColor        

        MintTokensSettingsPanel {
            id: panel

            MintedTokensModel {
                id: mintedTokensModel
            }

            SortFilterProxyModel {
                id: privilegedTokensModel

                sourceModel: mintedTokensModel

                filters: ValueFilter {
                    roleName: "isPrivilegedToken"
                    value: true
                }
            }

            anchors.fill: parent
            anchors.topMargin: 50

            // General:
            communityLogo: ModelsData.collectibles.doodles
            communityColor: "#FFC4E9"
            communityName: "Doodles" // It cannot be changed since owner token and tMaster token in tokenModel used are related to the `Doodles` community

            // Profile type:
            isAdmin: adminChecked.checked
            isOwner: ownerChecked.checked
            isTokenMasterOwner: masterTokenOwnerChecked.checked

            // Owner and TMaster related props:
            isOwnerTokenDeployed: deployCheck.checked
            isTMasterTokenDeployed: deployCheck.checked

            // Models:
            tokensModel: editorModelChecked.checked ? emptyModel :
                                                      privilegedModelChecked.checked ? privilegedTokensModel : mintedTokensModel
            layer1Networks: NetworksModel.layer1Networks
            layer2Networks: NetworksModel.layer2Networks
            testNetworks: NetworksModel.testNetworks
            enabledNetworks: NetworksModel.enabledNetworks
            allNetworks: enabledNetworks
            accounts: WalletAccountsModel {}
            tokensModelWallet: ListModel {
                ListElement {
                    symbol: "MAI"
                }
            }

            onMintCollectible: logs.logEvent("CommunityMintTokensSettingsPanel::mintCollectible")
            onMintAsset: logs.logEvent("CommunityMintTokensSettingsPanel::mintAssets")
            onDeleteToken: logs.logEvent("CommunityMintTokensSettingsPanel::deleteToken: " + tokenKey)
            onSignMintTransactionOpened: feesTimer.restart()
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 300

        logsView.logText: logs.logText

        ColumnLayout {
            CheckBox {
                id: ownerChecked
                checked: true

                text: "Is Owner? [Owner will be able to create an OWNER and TOKEN MASTER token]"
            }

            CheckBox {
                id: masterTokenOwnerChecked
                checked: true

                text: "Is TMaster token owner? [TMaster token owner will be able to mint / airdrop tokens once the TMaster is already created]"
            }

            CheckBox {
                id: adminChecked
                checked: true

                text: "Is admin? [Admis will be able to see token views, but NOT manage them, like creating new artwork or asset]"
            }

            RowLayout {
                RadioButton {
                    id: editorModelChecked

                    checked: true

                    text: "No tokens minted yet"
                }
                RadioButton {
                    id: privilegedModelChecked

                    text: "Owner token and TMaster token only"
                }
                RadioButton {
                    id: completeModelChecked

                    text: "Minted tokens list"
                }
            }

            RowLayout {

                RadioButton {
                    text: "Set all to 'In progress'"

                    onClicked: mintedTokensModel.changeAllMintingStates(1)
                }

                RadioButton {
                    text: "Set all to 'Error'"

                    onClicked: mintedTokensModel.changeAllMintingStates(0)
                }

                RadioButton {
                    id: deployCheck

                    text: "Set all to 'Deployed'"

                    onClicked: mintedTokensModel.changeAllMintingStates(2)
                }
            }
        }
    }
}
