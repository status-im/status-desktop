import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.14
import QtQuick.Window 2.12

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import shared.controls 1.0
import utils 1.0

import "../stores"
import "../controls"

Item {
    id: root

    property var currentAccount: RootStore.currentAccount
    property var contactsStore
    property var transaction
    property var sendModal

    signal goBack()

    QtObject {
        id: d
        readonly property bool isIncoming: root.transaction !== undefined && !!root.transaction ? root.transaction.to === currentAccount.address : false
        readonly property string savedAddressNameTo: root.transaction !== undefined && !!root.transaction ? d.getNameForSavedWalletAddress(transaction.to) : ""
        readonly property string savedAddressNameFrom: root.transaction !== undefined && !!root.transaction ? d.getNameForSavedWalletAddress(transaction.from): ""
        readonly property string from: root.transaction !== undefined && !!root.transaction ? !!savedAddressNameFrom ? savedAddressNameFrom : Utils.compactAddress(transaction.from, 4): ""
        readonly property string to: root.transaction !== undefined && !!root.transaction ? !!savedAddressNameTo ? savedAddressNameTo : Utils.compactAddress(transaction.to, 4): ""

        function getNameForSavedWalletAddress(address) {
            return RootStore.getNameForSavedWalletAddress(address)
        }
    }

    StatusFlatButton {
        id: backButton
        anchors.top: parent.top
        anchors.left: parent.left
        Layout.alignment: Qt.AlignTop
        anchors.topMargin: -Style.current.xlPadding
        anchors.leftMargin: -Style.current.xlPadding
        icon.name: "arrow-left"
        icon.width: 20
        icon.height: 20
        text: qsTr("Activity")
        size: StatusBaseButton.Size.Large
        onClicked: root.goBack()
    }

    StatusScrollView {
        anchors.top: backButton.bottom
        anchors.left: parent.left

        width: parent.width
        height: parent.height
        contentHeight: column.height
        contentWidth: parent.width

        Column {
            id: column
            width: parent.width - Style.current.xlPadding

            spacing: Style.current.bigPadding

            TransactionDelegate {
                objectName: "transactionDetailHeader"
                width: parent.width

                modelData: transaction
                isIncoming: d.isIncoming
                currentCurrency: RootStore.currentCurrency
                cryptoValue: root.transaction !== undefined && !!root.transaction ? RootStore.hex2Eth(transaction.value): ""
                fiatValue: root.transaction !== undefined && !!root.transaction ? RootStore.getFiatValue(cryptoValue, resolvedSymbol, RootStore.currentCurrency): ""
                networkIcon: root.transaction !== undefined && !!root.transaction ? RootStore.getNetworkIcon(transaction.chainId): ""
                networkColor: root.transaction !== undefined && !!root.transaction ? RootStore.getNetworkColor(transaction.chainId): ""
                networkName: root.transaction !== undefined && !!root.transaction ? RootStore.getNetworkShortName(transaction.chainId): ""
                symbol: root.transaction !== undefined && !!root.transaction ? RootStore.findTokenSymbolByAddress(transaction.contract): ""
                transferStatus: root.transaction !== undefined && !!root.transaction ? RootStore.hex2Dec(transaction.txStatus): ""
                shortTimeStamp: root.transaction !== undefined && !!root.transaction ? Utils.formatShortTime(transaction.timestamp * 1000, RootStore.accountSensitiveSettings.is24hTimeFormat): ""
                savedAddressName: root.transaction !== undefined && !!root.transaction ? RootStore.getNameForSavedWalletAddress(transaction.to): ""
                title: d.isIncoming ? qsTr("Received %1 %2 from %3").arg(cryptoValue).arg(resolvedSymbol).arg(d.from) :
                                    qsTr("Sent %1 %2 to %3").arg(cryptoValue).arg(resolvedSymbol).arg(d.to)
                sensor.enabled: false
                color: Theme.palette.statusListItem.backgroundColor
                state: "big"
            }

            SavedAddressesDelegate {
                width: parent.width

                name: d.isIncoming ? d.savedAddressNameFrom : d.savedAddressNameTo
                address:  root.transaction !== undefined && !!root.transaction ? d.isIncoming ? transaction.from : transaction.to : ""
                title: d.isIncoming ? d.from : d.to
                subTitle:  root.transaction !== undefined && !!root.transaction ? d.isIncoming ? !!d.savedAddressNameFrom ? Utils.compactAddress(transaction.from, 4) : "" : !!d.savedAddressNameTo ? Utils.compactAddress(transaction.to, 4) : "": ""
                store: RootStore
                contactsStore: root.contactsStore
                onOpenSendModal: root.sendModal.open(address);
                saveAddress: function(name, address, favourite) {
                    RootStore.createOrUpdateSavedAddress(name, address, favourite)
                }
                deleteSavedAddress: function(address) {
                    RootStore.deleteSavedAddress(address)
                }
            }

            StatusExpandableItem {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                type: StatusExpandableItem.Type.Tertiary
                expandable: true
                primaryText: qsTr("Transaction summary")
                expandableComponent: transactionSummary
                separatorVisible: false
                expanded: true
            }

            StatusExpandableItem {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                type: StatusExpandableItem.Type.Tertiary
                expandable: true
                primaryText: qsTr("Fees")
                expandableComponent: fees
                expanded: true
            }

            StatusListItem {
                id: data
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                color: "transparent"
                border.width: 1
                border.color: Theme.palette.directColor8

                statusListItemTitle.color: Theme.palette.baseColor1

                title: qsTr("Data" )
                subTitle: root.transaction !== undefined && !!root.transaction ? root.transaction.input : ""
                components: [
                    CopyToClipBoardButton {
                        icon.width: 15
                        icon.height: 15
                        type: StatusRoundButton.Type.Tertiary
                        color: "transparent"
                        icon.color: data.showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1
                        store: RootStore
                        textToCopy: data.subTitle
                    }
                ]
            }
        }
    }


    Component {
        id: transactionSummary
        Column {
            id: column
            width: parent.width
            spacing: 8
            TransactionDelegate {
                width: parent.width
                modelData: transaction
                isIncoming: d.isIncoming
                currentCurrency: RootStore.currentCurrency
                cryptoValue: root.transaction !== undefined && !!root.transaction ? RootStore.hex2Eth(transaction.value): ""
                fiatValue: RootStore.getFiatValue(cryptoValue, resolvedSymbol, RootStore.currentCurrency)
                networkIcon: root.transaction !== undefined && !!root.transaction ? RootStore.getNetworkIcon(transaction.chainId) : ""
                networkColor: root.transaction !== undefined && !!root.transaction ? RootStore.getNetworkColor(transaction.chainId): ""
                networkName: root.transaction !== undefined && !!root.transaction ? RootStore.getNetworkShortName(transaction.chainId): ""
                symbol: root.transaction !== undefined && !!root.transaction ? RootStore.findTokenSymbolByAddress(transaction.contract): ""
                transferStatus: root.transaction !== undefined && !!root.transaction ? RootStore.hex2Dec(transaction.txStatus): ""
                shortTimeStamp: root.transaction !== undefined && !!root.transaction ? Utils.formatShortTime(transaction.timestamp * 1000, RootStore.accountSensitiveSettings.is24hTimeFormat): ""
                savedAddressName: root.transaction !== undefined && !!root.transaction ? RootStore.getNameForSavedWalletAddress(transaction.to): ""
                title: d.isIncoming ? qsTr("Received %1 %2 from %3").arg(cryptoValue).arg(resolvedSymbol).arg(d.from) :
                                    qsTr("Sent %1 %2 to %3").arg(cryptoValue).arg(resolvedSymbol).arg(d.to)
                sensor.enabled: false
                color: Theme.palette.statusListItem.backgroundColor
                border.width: 1
                border.color: Theme.palette.directColor8
            }
            Row {
                spacing: 8
                InformationTile {
                    maxWidth: parent.width
                    primaryText: qsTr("Time")
                    secondaryText:  root.transaction !== undefined && !!root.transaction ? qsTr("%1 <font color=\"#939BA1\">on</font> %2").
                                                                     arg(Utils.formatShortTime(transaction.timestamp * 1000, RootStore.accountSensitiveSettings.is24hTimeFormat)).
                                                                     arg(Utils.formatShortDate(transaction.timestamp * 1000, RootStore.accountSensitiveSettings.is24hTimeFormat)): ""
                }
                InformationTile {
                    maxWidth: parent.width
                    primaryText: qsTr("Confirmations")
                    secondaryText: {
                        if(root.transaction !== undefined && !!root.transaction )
                            return Math.abs(RootStore.getLatestBlockNumber() - RootStore.hex2Dec(root.transaction.blockNumber))
                        else
                            return ""
                    }
                }
                InformationTile {
                    maxWidth: parent.width
                    primaryText: qsTr("Nonce")
                    secondaryText: root.transaction !== undefined && !!root.transaction ? RootStore.hex2Dec(root.transaction.nonce) : ""
                }
            }
        }
    }

    Component {
        id: fees
        Column {
            width: parent.width
            spacing: 8
            Row {
                spacing: 8
                InformationTile {
                    id: baseFee
                    maxWidth: parent.width
                    primaryText: qsTr("Base fee")
                    secondaryText: root.transaction !== undefined && !!root.transaction ?  qsTr("%1 Gwei").arg(RootStore.hex2Gwei(root.transaction.baseGasFees)) : ""
                }
                InformationTile {
                    maxWidth: parent.width
                    primaryText: qsTr("Tip")
                    secondaryText: root.transaction !== undefined && !!root.transaction ?  qsTr("%1 Gwei <font color=\"#939BA1\">&#8226; Max: %2 Gwei</font>").
                                                                    arg(RootStore.hex2Gwei(root.transaction.maxPriorityFeePerGas)).
                                                                    arg(RootStore.hex2Gwei(root.transaction.maxFeePerGas)) : ""
                    secondaryLabel.textFormat: Text.RichText
                }
            }
            InformationTile {
                maxWidth: parent.width
                primaryText: qsTr("Total fee")
                secondaryText: root.transaction !== undefined && !!root.transaction ? qsTr("%1 Gwei <font color=\"#939BA1\">&#8226; Max: %2 Gwei</font>").
                                                                arg(Utils.stripTrailingZeros(RootStore.hex2Gwei(root.transaction.totalFees))).
                                                                arg(Utils.stripTrailingZeros(RootStore.hex2Gwei(root.transaction.maxTotalFees))) : ""
                secondaryLabel.textFormat: Text.RichText
            }
        }
    }
}
