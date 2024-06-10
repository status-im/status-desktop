import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Popups.Dialog 0.1
import StatusQ.Controls 0.1

import shared.popups.send.controls 1.0

import AppLayouts.Wallet.controls 1.0

StatusDialog {
    id: root

    /* This should be the only property which should be used to input
    parameters to the modal when being launched from elsewhere */
    required property SwapInputParamsForm swapInputParamsForm
    required property SwapModalAdaptor swapAdaptor

    objectName: "swapModal"

    implicitWidth: 556
    topPadding: 0
    bottomPadding: Style.current.xlPadding
    leftPadding: Style.current.xlPadding
    rightPadding: Style.current.xlPadding
    backgroundColor: Theme.palette.baseColor3

    Behavior on implicitHeight {
        NumberAnimation { duration: 1000; easing.type: Easing.OutExpo; alwaysRunToEnd: true}
    }

    header: AccountsModalHeader {
        anchors.top: parent.top
        anchors.topMargin: -height - 18
        control.popup.width: 512
        model: root.swapAdaptor.nonWatchAccounts
        getNetworkShortNames: root.swapAdaptor.getNetworkShortNames
        formatCurrencyAmount: root.swapAdaptor.formatCurrencyAmount
        /* TODO: once the Account Header is reworked we simply should be
        able to use an index and not this logic of selectedAccount being set */
        selectedAccount: root.swapAdaptor.getSelectedAccount(root.swapInputParamsForm.selectedAccountIndex)
        onSelectedIndexChanged: {
            root.swapInputParamsForm.selectedAccountIndex = selectedIndex
        }
    }

    contentItem: ColumnLayout {
        spacing: 5
        clip: true

        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            HeaderTitleText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                id: modalHeader
                text: qsTr("Swap")
            }
            StatusBaseText {
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                text: qsTr("On:")
                color: Theme.palette.baseColor1
                font.pixelSize: 13
                lineHeight: 38
                lineHeightMode: Text.FixedHeight
                verticalAlignment: Text.AlignVCenter
            }
            // TODO: update this once https://github.com/status-im/status-desktop/issues/14780 is ready
            NetworkFilter {
                id: networkFilter
                objectName: "networkFilter"
                Layout.alignment: Qt.AlignVCenter
                multiSelection: false
                showRadioButtons: false
                showTitle: false
                flatNetworks: root.swapAdaptor.filteredFlatNetworksModel
                onToggleNetwork: (network) => {
                                     root.swapInputParamsForm.selectedNetworkChainId = network.chainId
                                 }
                Component.onCompleted: {
                    if(root.swapInputParamsForm.selectedNetworkChainId !== -1)
                        networkFilter.setChain(root.swapInputParamsForm.selectedNetworkChainId)
                }
            }
        }

        // This is a temporary placeholder while each of the components are  being added.
        StatusBaseText {
            topPadding: Style.current.padding
            text: qsTr("This area is a temporary placeholder")
            font.bold: true
        }
        StatusBaseText {
            text: qsTr("Selected from token: %1").arg(swapInputParamsForm.fromTokensKey)
        }
        StatusBaseText {
            text: qsTr("from token amount: %1").arg(swapInputParamsForm.fromTokenAmount)
        }
        StatusBaseText {
            text: qsTr("Selected to token: %1").arg(swapInputParamsForm.toTokenKey)
        }
        StatusBaseText {
            text: qsTr("to token amount: %1").arg(swapInputParamsForm.toTokenAmount)
        }
        StatusButton {
            text: "Fetch Suggested Routes"
            onClicked: {
                swapAdaptor.fetchSuggestedRoutes()
            }
        }
        StatusButton {
            text: "Send Approve Tx"
            onClicked: {
                swapAdaptor.sendApproveTx()
            }
        }
        StatusButton {
            text: "Send Swap Tx"
            onClicked: {
                swapAdaptor.sendSwapTx()
            }
        }
        StatusScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: 200

            StatusTextArea {
                text: {
                    let routes = SQUtils.ModelUtils.modelToArray(swapAdaptor.suggestedRoutes)
                    let routesString = JSON.stringify(routes, null, "  ")
                    return qsTr("Suggested routes: \n%1").arg(routesString)
                }
            }
        }
        // End temporary placeholders

        EditSlippagePanel {
            id: editSlippagePanel
            objectName: "editSlippagePanel"
            Layout.fillWidth: true
            Layout.topMargin: Style.current.padding
            visible: editSlippageButton.checked
            selectedToToken: root.swapAdaptor.toToken
            toTokenAmount: root.swapInputParamsForm.toTokenAmount
            loading: root.swapAdaptor.swapProposalLoading
            onSlippageValueChanged: {
                root.swapInputParamsForm.selectedSlippage = slippageValue
            }
        }
    }

    footer: StatusDialogFooter {
        color: Theme.palette.baseColor3
        dropShadowEnabled: true
        leftButtons: ObjectModel {
            ColumnLayout {
                Layout.leftMargin: Style.current.padding
                spacing: 0
                StatusBaseText {
                    objectName: "maxSlippageText"
                    text: qsTr("Max slippage:")
                    color: Theme.palette.directColor5
                    font.pixelSize: 15
                    font.weight: Font.Medium
                }
                RowLayout {
                    StatusBaseText {
                        objectName: "maxSlippageValue"
                        text: "%1%".arg(LocaleUtils.numberToLocaleString(root.swapInputParamsForm.selectedSlippage))
                        color: Theme.palette.directColor4
                        font.pixelSize: 15
                        font.weight: Font.Medium
                    }
                    StatusFlatButton {
                        id: editSlippageButton
                        objectName: "editSlippageButton"
                        checkable: true
                        checked: false
                        icon.name: "edit_pencil"
                        textColor: editSlippageButton.hovered ? Theme.palette.directColor1 : Theme.palette.directColor5
                        size: StatusBaseButton.Size.Tiny
                        hoverColor: Theme.palette.transparent
                        visible: !checked
                    }
                }
            }
        }
        rightButtons: ObjectModel {
            RowLayout {
                Layout.rightMargin: Style.current.padding
                spacing: Style.current.bigPadding
                ColumnLayout {
                    StatusBaseText {
                        text:qsTr("Max fees:")
                        color: Theme.palette.directColor5
                        font.pixelSize: 15
                        font.weight: Font.Medium
                    }
                    StatusTextWithLoadingState {
                        text: loading ? Constants.dummyText : "--"
                        customColor: Theme.palette.directColor4
                        font.pixelSize: 15
                        font.weight: Font.Medium
                        loading: root.swapAdaptor.swapProposalLoading
                    }
                }
                StatusButton {
                    objectName: "signButton"
                    /* TODO: there maybe a different icon shown here in case of approval of spending cap
                       needed TBD under https://github.com/status-im/status-desktop/issues/14833 */
                    icon.name: "password"
                    text: qsTr("Swap")
                    disabledColor: Theme.palette.directColor8
                    enabled: root.swapAdaptor.swapProposalReady && editSlippagePanel.valid
                }
            }
        }
    }
}

