import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qt.labs.settings 1.0

import AppLayouts.Communities.panels 1.0
import AppLayouts.Chat.stores 1.0
import StatusQ.Core.Theme 0.1

import SortFilterProxyModel 0.2

import Storybook 1.0
import Models 1.0
import utils 1.0

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
        id: timer
        function delay(delayTime, cb) {
            timer.interval = delayTime;
            timer.repeat = false;
            timer.triggered.connect(cb);
            timer.start();
        }
    }

    Rectangle {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        color: Theme.palette.statusAppLayout.rightPanelBackgroundColor

        MintTokensSettingsPanel {
            id: panel

            readonly property var singleTransactionFee: {
                "ethCurrency": {
                    "objectName":"",
                    "amount":0.000007900500349933282,
                    "symbol":"ETH",
                    "displayDecimals":4,
                    "stripTrailingZeroes":false
                },
                "fiatCurrency": {
                    "objectName":"",
                    "amount":0.012852533720433712,
                    "symbol":"USD",
                    "displayDecimals":2,
                    "stripTrailingZeroes":false
                },
                "errorCode":0
            }

            MintedTokensModel {
                id: mintedTokensModel
            }

            SortFilterProxyModel {
                id: privilegedTokensModel

                sourceModel: mintedTokensModel

                filters: [
                    ExpressionFilter {
                        readonly property int ownerLevel: Constants.TokenPrivilegesLevel.Owner
                        readonly property int tMasterLevel: Constants.TokenPrivilegesLevel.TMaster

                        expression: {
                            return ((model.privilegesLevel === ownerLevel) ||
                                    (model.privilegesLevel === tMasterLevel))
                        }
                    }
                ]
            }

            anchors.fill: parent
            anchors.topMargin: 50

            // General:
            communityLogo: ModelsData.collectibles.doodles
            communityColor: "#FFC4E9"
            communityName: "Doodles" // It cannot be changed since owner token and tMaster token in tokenModel used are related to the `Doodles` community
            communityId: ""

            // Profile type:
            isAdmin: adminChecked.checked
            isOwner: ownerChecked.checked
            isTokenMasterOwner: masterTokenOwnerChecked.checked

            // Owner and TMaster related props:
            isOwnerTokenDeployed: deployCheck.checked
            isTMasterTokenDeployed: deployCheck.checked
            anyPrivilegedTokenFailed: failedCheck.checked

            // Models:
            tokensModel: editorModelChecked.checked ? emptyModel :
                                                      privilegedModelChecked.checked ? privilegedTokensModel : mintedTokensModel
            layer1Networks: NetworksModel.layer1Networks
            layer2Networks: NetworksModel.layer2Networks
            enabledNetworks: NetworksModel.enabledNetworks
            allNetworks: enabledNetworks
            accounts: WalletAccountsModel {}
            referenceAssetsBySymbolModel: ListModel {
                ListElement {
                    name: "eth"
                    symbol: "ETH"
                }
                ListElement {
                    name: "dai"
                    symbol: "DAI"
                }
                ListElement {
                    name: "snt"
                    symbol: "SNT"
                }
            }

            onMintCollectible: logs.logEvent("CommunityMintTokensSettingsPanel::mintCollectible")
            onMintAsset: logs.logEvent("CommunityMintTokensSettingsPanel::mintAssets")
            onDeleteToken: logs.logEvent("CommunityMintTokensSettingsPanel::deleteToken: " + tokenKey)
            onRegisterDeployFeesSubscriber: timer.delay(2000, () => feeSubscriber.feesResponse = panel.singleTransactionFee)
            onRegisterSelfDestructFeesSubscriber: timer.delay(2000, () => feeSubscriber.feesResponse = panel.singleTransactionFee)
            onRegisterBurnTokenFeesSubscriber: timer.delay(2000, () => feeSubscriber.feesResponse = panel.singleTransactionFee)
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
                    id: failedCheck

                    text: "Set all to 'Error'"
                    checked: true

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

    Settings {
        property alias editorModelChecked: editorModelChecked.checked
        property alias privilegedModelChecked: privilegedModelChecked.checked
        property alias completeModelChecked: completeModelChecked.checked
    }
}

// category: Panels

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=22721%3A498587&t=v2Krj5iZQaSTK7Om-1
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2934%3A480877&t=v2Krj5iZQaSTK7Om-1
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=22721%3A498811&t=v2Krj5iZQaSTK7Om-1
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2934%3A480927&t=v2Krj5iZQaSTK7Om-1
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?type=design&node-id=29566-689073&t=mAtmLENvQyRJqDGQ-0
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?type=design&node-id=29437-599353&t=mAtmLENvQyRJqDGQ-0
