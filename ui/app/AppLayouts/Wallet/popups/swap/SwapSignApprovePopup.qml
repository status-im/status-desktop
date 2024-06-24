import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import shared.controls 1.0

import AppLayouts.Wallet 1.0
import AppLayouts.Wallet.controls 1.0

import utils 1.0

// TODO: this is only temporary placeholder and should be replaced completely by https://github.com/status-im/status-desktop/issues/14785
StatusDialog {
    id: root

    required property bool loading
    required property SwapSignApproveInputForm swapSignApproveInputForm
    required property SwapSignApproveAdaptor adaptor

    signal sign()
    signal reject()

    objectName: "swapSignApproveModal"
    implicitWidth: 480
    padding: 20
    title: qsTr("Approve spending cap")
    /* TODO: https://github.com/status-im/status-desktop/issues/15329
    This is only added temporarily until we have an api from the backend in order to get
    this list dynamically */
    subtitle: Constants.swap.paraswapUrl

    contentItem: StatusScrollView {
        id: scrollView
        padding: 0
        ColumnLayout {
            spacing: Style.current.bigPadding
            clip: true

            width: scrollView.availableWidth

            Column {
                width: scrollView.availableWidth
                spacing: Style.current.padding
                StatusBaseText {
                    width: parent.width
                    text: qsTr("Set spending cap")
                }
                StatusListItem {
                    width: parent.width
                    title: SQUtils.AmountsArithmetic.div(
                               SQUtils.AmountsArithmetic.fromString(swapSignApproveInputForm.approvalAmountRequired),
                               SQUtils.AmountsArithmetic.fromNumber(1, !!root.adaptor.fromToken ? root.adaptor.fromToken.decimals: 18)).toString()
                    border.width: 1
                    border.color: Theme.palette.baseColor2
                    components: [
                        StatusSmartIdenticon {
                            asset.name: !!root.adaptor.fromToken ?
                                            Constants.tokenIcon(root.adaptor.fromToken.symbol): ""
                            asset.isImage: true
                            asset.width: 20
                            asset.height: 20
                        },
                        StatusBaseText {
                            text: !!root.adaptor.fromToken ?
                                      root.adaptor.fromToken.symbol ?? "" : ""
                        }
                    ]
                }
            }

            Column {
                width: scrollView.availableWidth
                spacing: Style.current.padding
                StatusBaseText {
                    width: parent.width
                    text: qsTr("Account")
                }
                WalletAccountListItem {
                    width: parent.width
                    height: 76
                    border.width: 1
                    border.color: Theme.palette.baseColor2
                    name: !!root.adaptor.selectedAccount ? root.adaptor.selectedAccount.name: ""
                    address: !!root.adaptor.selectedAccount ? root.adaptor.selectedAccount.address: ""
                    chainShortNames: !!root.adaptor.selectedAccount ? root.adaptor.selectedAccount.colorizedChainPrefixes ?? "" : ""
                    emoji:  !!root.adaptor.selectedAccount ? root.adaptor.selectedAccount.emoji: ""
                    walletColor: Utils.getColorForId(!!root.adaptor.selectedAccount ? root.adaptor.selectedAccount.colorId : "")
                    currencyBalance:  !!root.adaptor.selectedAccount ? root.adaptor.selectedAccount.currencyBalance: ""
                    walletType: !!root.adaptor.selectedAccount ? root.adaptor.selectedAccount.walletType: ""
                    migratedToKeycard:  !!root.adaptor.selectedAccount ? root.adaptor.selectedAccount.migratedToKeycard ?? false : false
                    accountBalance: !!root.adaptor.selectedAccount ? root.adaptor.selectedAccount.accountBalance : null
                }
            }

            Column {
                width: scrollView.availableWidth
                spacing: Style.current.padding
                StatusBaseText {
                    width: parent.width
                    text: qsTr("Token")
                }
                StatusListItem {
                    width: parent.width
                    height: 76
                    border.width: 1
                    border.color: Theme.palette.baseColor2
                    asset.name: !!root.adaptor.fromToken ?
                                    Constants.tokenIcon(root.adaptor.fromToken.symbol): ""
                    asset.isImage: true
                    title: !!root.adaptor.fromToken ?
                               root.adaptor.fromToken.symbol  ?? "" : ""
                    subTitle: SQUtils.Utils.elideText(contractAddressOnSelectedNetwork.item.address, 6, 4)
                    ModelEntry {
                        id: contractAddressOnSelectedNetwork
                        sourceModel: !!root.adaptor.fromToken ?
                                         root.adaptor.fromToken.addressPerChain ?? null : null
                        key: "chainId"
                        value: root.swapSignApproveInputForm.selectedNetworkChainId
                    }
                    components: [
                        StatusRoundButton {
                            type: StatusRoundButton.Type.Quinary
                            radius: 8
                            icon.name: "more"
                            icon.color: Theme.palette.directColor5
                            onClicked: {}
                        }
                    ]
                }
            }

            Column {
                width: scrollView.availableWidth
                spacing: Style.current.padding
                StatusBaseText {
                    width: parent.width
                    text: qsTr("Via smart contract")
                }
                StatusListItem {
                    width: parent.width
                    height: 76
                    border.width: 1
                    border.color: Theme.palette.baseColor2
                    title: root.swapSignApproveInputForm.swapProviderName
                    subTitle: SQUtils.Utils.elideText(root.swapSignApproveInputForm.approvalContractAddress, 6, 4)
                    /* TODO: https://github.com/status-im/status-desktop/issues/15329
                    This is only added temporarily until we have an api from the backend in order to get
                    this list dynamically */
                    asset.name: Style.png("swap/%1".arg(Constants.swap.paraswapIcon))
                    asset.isImage: true
                    components: [
                        StatusRoundButton {
                            type: StatusRoundButton.Type.Quinary
                            radius: 8
                            icon.name: "more"
                            icon.color: Theme.palette.directColor5
                            onClicked: {}
                        }
                    ]
                }
            }

            Column {
                width: scrollView.availableWidth
                spacing: Style.current.padding
                StatusBaseText {
                    width: parent.width
                    text: qsTr("Network")
                }
                StatusListItem {
                    width: parent.width
                    height: 76
                    border.width: 1
                    border.color: Theme.palette.baseColor2
                    asset.name: !!root.adaptor.selectedNetwork ?
                                    root.adaptor.selectedNetwork.isTest ?
                                        Style.svg(root.adaptor.selectedNetwork.iconUrl + "-test") :
                                        Style.svg(root.adaptor.selectedNetwork.iconUrl): ""
                    asset.isImage: true
                    asset.color: "transparent"
                    asset.bgColor: "transparent"
                    title: !!root.adaptor.selectedNetwork ?
                               root.adaptor.selectedNetwork.chainName ?? "" : ""
                }
            }

            Column {
                width: scrollView.availableWidth
                spacing: Style.current.padding
                StatusBaseText {
                    width: parent.width
                    text: qsTr("Fees")
                }
                StatusListItem {
                    width: parent.width
                    height: 76
                    border.width: 1
                    border.color: Theme.palette.baseColor2
                    title: qsTr("Max. fees on %1").arg(!!root.adaptor.selectedNetwork ?
                                                           root.adaptor.selectedNetwork.chainName : "")
                    components: [
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            StatusTextWithLoadingState   {
                                anchors.right: parent.right
                                loading: root.loading
                                text: {
                                    let feesInFoat = root.adaptor.currencyStore.getFiatValue(root.swapSignApproveInputForm.approvalGasFees, Constants.ethToken)
                                    return root.adaptor.currencyStore.formatCurrencyAmount(feesInFoat, root.adaptor.currencyStore.currentCurrency)
                                }
                            }
                            StatusTextWithLoadingState   {
                                anchors.right: parent.right
                                loading: root.loading
                                text: root.adaptor.currencyStore.formatCurrencyAmount(root.swapSignApproveInputForm.approvalGasFees, Constants.ethToken)
                            }
                        }
                    ]
                }
            }
        }
    }

    footer: StatusDialogFooter {
        spacing: Style.current.xlPadding
        leftButtons: ObjectModel {
            SwapModalFooterInfoComponent {
                titleText: qsTr("Max fees:")
                infoText: {
                    let feesInFoat = root.adaptor.currencyStore.getFiatValue(root.swapSignApproveInputForm.approvalGasFees, Constants.ethToken)
                    return root.adaptor.currencyStore.formatCurrencyAmount(feesInFoat, root.adaptor.currencyStore.currentCurrency)
                }
                loading: root.loading
            }
            SwapModalFooterInfoComponent {
                Layout.maximumWidth: 60
                titleText: qsTr("Est. time:")
                infoText: WalletUtils.getLabelForEstimatedTxTime(root.swapSignApproveInputForm.estimatedTime)
                loading: root.loading
            }
        }

        rightButtons: ObjectModel {
            StatusButton {
                objectName: "rejectButton"
                text: qsTr("Reject")
                normalColor: Theme.palette.transparent
                onClicked: root.reject()
            }
            StatusButton {
                objectName: "signButton"
                icon.name: "password"
                text: qsTr("Sign")
                disabledColor: Theme.palette.directColor8
                enabled: !root.loading
                onClicked: root.sign()
            }
        }
    }
}
