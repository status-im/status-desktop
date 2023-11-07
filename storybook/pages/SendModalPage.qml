import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import Storybook 1.0
import utils 1.0

import shared.popups.send 1.0
import shared.stores 1.0
import shared.stores.send 1.0

SplitView {
    id: root

    orientation: Qt.Horizontal

    TransactionStore {
        id: txStore
    }

    QtObject {
        id: dummyEventData

        property ListModel toModel: ListModel {
            ListElement {
                chainId: 420
                chainName: "Optimism"
                iconUrl: "network/Network=Optimism"
                amountOut: "3003845308235848343"
            }
        }
        property var suggestesRoutes: [{
                bridgeName:"Hop",
                fromNetwork: 1,
                toNetwork: 10,
                maxAmountIn:"2649485258572837546",
                amountIn:"200000000000000000",
                amountOut:"200000000000000000",
                gasAmount:501000,
                gasFees: {
                    gasPrice:1.7e-08,
                    baseFee:1.0,
                    maxPriorityFeePerGas:2e-09,
                    maxFeePerGasL:1.1e-08,
                    maxFeePerGasM:1.0,
                    maxFeePerGasH:2.0,
                    eip1559Enabled:true
                },
                tokenFees:-0.004508663259772343,
                cost:-6.39534887667951,
                estimatedTime:1,
                amountInLocked:false,
                isFirstSimpleTx:true,
                isFirstBridgeTx:true,
                approvalRequired:false,
                approvalGasFees:0.0,
                approvalAmountRequired:"0",
                approvalContractAddress:""
            },
            {
                bridgeName:"Transfer",
                fromNetwork: 10,
                toNetwork:10,
                maxAmountIn:"443890157817650036",
                amountIn:"200000000000000000",
                amountOut:"200000000000000000",
                gasAmount:22000,
                gasFees:{
                    gasPrice:0.10000005,
                    baseFee:4.4e-08,
                    maxPriorityFeePerGas:0.1,
                    maxFeePerGasL:5e-08,
                    maxFeePerGasM:0.1,
                    maxFeePerGasH:0.2,
                    eip1559Enabled:true
                },
                tokenFees:0.0,
                bonderFees:"0x0",
                cost:0.003510716,
                estimatedTime:1,
                amountInLocked:false,
                isFirstSimpleTx:false,
                isFirstBridgeTx:false,
                approvalRequired:false,
                approvalGasFees:0.0,
                approvalAmountRequired:"0",
                approvalContractAddress:""
            }]
    }

    Item {
        anchors.left: parent.left
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            anchors.fill: parent
            color: "lightgray"
        }

        Loader {
            id: loader

            property var preSelectedAccount: txStore.selectedSenderAccount
            property string preSelectedHoldingID
            property int preSelectedHoldingType: Constants.TokenType.Unknown
            property int preSelectedSendType: Constants.SendType.Unknown
            property bool onlyAssets: false
            property string preDefinedAmountToSend
            property string preSelectedRecipient

            active: false

            sourceComponent: SendModal {
                visible: true
                modal: false
                closePolicy: Popup.NoAutoClose
                onlyAssets: false
                store: txStore
                preSelectedAccount: loader.preSelectedAccount
                preDefinedAmountToSend: loader.preDefinedAmountToSend
                preSelectedRecipient: loader.preSelectedRecipient
                preSelectedSendType: loader.preSelectedSendType
                preSelectedHoldingID: loader.preSelectedHoldingID
                preSelectedHoldingType: loader.preSelectedHoldingType
            }
            Component.onCompleted: loader.active = true
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 100


        ColumnLayout {
            width: parent.width
            spacing: 20

            ColumnLayout {
                spacing: 0
                Layout.topMargin: 20
                width: parent.width
                StatusBaseText {
                    Layout.maximumWidth: parent.width
                    text: "This button can be used as respons eot the suggestedROutes API called once a token and its amount is selected along with a valid recipient."
                    color: "orange"
                    wrapMode: Text.WrapAnywhere
                }
                StatusButton {
                    enabled: txStore.suggestedRoutesCalled
                    text: "emit suggestedRoutesReady"
                    onClicked: {
                        let txRoutes = {
                            suggestedRoutes: dummyEventData.suggestesRoutes,
                            gasTimeEstimate:{
                                totalFeesInEth:0.0005032000000000001,
                                totalTokenFees:-0.004508663259772343,
                                totalTime:2
                            },
                            amountToReceive: txStore.amountToSend - (txStore.amountToSend*5/100),
                            toNetworksModel: dummyEventData.toModel
                        }
                        txStore.fromNetworksModel.updateFromNetworks(dummyEventData.suggestesRoutes)
                        txStore.toNetworksModel.updateToNetworks(dummyEventData.suggestesRoutes)
                        txStore.walletSectionSendInst.suggestedRoutesReady(txRoutes)
                        txStore.suggestedRoutesCalled = false
                    }
                }
            }

            Rectangle {
                Layout.fillWidth:  true
                Layout.preferredHeight: 1
                color: "grey"
            }

            StatusBaseText {
                Layout.maximumWidth: parent.width
                text: "Note: After filling in the preSelected inputs you need to reload the SendModal as per current implementation"
                color: "orange"
                wrapMode: Text.WrapAnywhere
            }

            ColumnLayout {
                spacing: 0
                StatusBaseText {
                    text:"preSelectedAccount"
                }
                ComboBox {
                    textRole: "name"
                    model: txStore.senderAccounts
                    onCurrentIndexChanged: loader.preSelectedAccount = txStore.senderAccounts.get(currentIndex)
                }
            }

            ColumnLayout {
                spacing: 0
                StatusBaseText {
                    text:"preSelectedHoldingType"
                }
                ComboBox {
                    id: tokenType
                    model: ["Native", "Asset", "Collectible", "Fungible Token", "Unknown", "ENS"]
                    currentIndex: 4
                    onCurrentIndexChanged: {
                        loader.preSelectedHoldingType = currentIndex
                    }
                }
            }

            StatusInput {
                enabled: tokenType.currentIndex > 0 && tokenType.currentIndex < 3
                label: "preSelectedHoldingID (case sensitive)"
                onTextChanged: loader.preSelectedHoldingID = text
            }

            StatusInput {
                label: "preDefinedAmountToSend"
                onTextChanged: loader.preDefinedAmountToSend = text
            }

            ColumnLayout {
                spacing: 0
                StatusBaseText {
                    text:"preSelectedSendType"
                }
                ComboBox {
                    model: ["Transfer",
                        "ENSRegister",
                        "ENSRelease",
                        "ENSSetPubKey",
                        "StickersBuy",
                        "Bridge",
                        "ERC721Transfer",
                        "Unknown"]
                    onCurrentIndexChanged: loader.preSelectedSendType = currentIndex
                }
            }

            StatusInput {
                label: "preSelectedRecipient"
                onTextChanged: loader.preSelectedRecipient = text
            }

            StatusButton {
                text: "Reload popup"
                onClicked: {
                    loader.item.close()
                    loader.item.open()
                }
            }
        }
    }
}

// category: Popups
