import QtQuick 2.13
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import "../panels"
import "../popups"
import "../stores"
import "../controls"

ColumnLayout {
    id: historyView

    property var account
    property int pageSize: 20 // number of transactions per page
    property bool isLoading: false

    signal launchTransactionDetail(var transaction)

    function fetchHistory() {
        if (RootStore.isFetchingHistory(historyView.account.address)) {
            isLoading = true
        } else {
            RootStore.loadTransactionsForAccount(historyView.account.address, pageSize)
        }
    }

    Connections {
        target: RootStore.history
        onLoadingTrxHistoryChanged: function(isLoading, address) {
            if (historyView.account.address.toLowerCase() === address.toLowerCase()) {
                historyView.isLoading = isLoading
            }
        }
    }

    Loader {
        id: loadingImg
        active: isLoading
        sourceComponent: loadingImageComponent
        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
        Layout.rightMargin: Style.current.padding
    }

    StyledText {
        id: nonArchivalNodeError
        Layout.alignment: Qt.AlignTop

        visible: RootStore.isNonArchivalNode
        text: qsTr("Status Desktop is connected to a non-archival node. Transaction history may be incomplete.")
        font.pixelSize: Style.current.primaryTextFontSize
        color: Style.current.danger
    }

    StyledText {
        id: noTxs
        visible: transactionListRoot.count === 0
        text: qsTr("No transactions found")
        font.pixelSize: Style.current.primaryTextFontSize
    }

    StatusListView {
        id: transactionListRoot
        objectName: "walletAccountTransactionList"
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: nonArchivalNodeError.visible || noTxs.visible ? Style.current.padding : 0
        Layout.bottomMargin:  Style.current.padding
        Layout.fillWidth: true
        Layout.fillHeight: true

        model: RootStore.historyTransactions
        delegate: Loader {
            width: parent.width
            sourceComponent: isTimeStamp ? dateHeader : transactionDelegate
            onLoaded:  {
                item.modelData = model
            }
        }       

        ScrollBar.vertical: StatusScrollBar {}

        footer:  StatusButton {
            id: loadMoreButton
            anchors.horizontalCenter: parent.horizontalCenter

            text: qsTr("Load More")
            // TODO: handle case when requested limit === transaction count -- there
            // is currently no way to know that there are no more results
            enabled: !isLoading && RootStore.historyTransactions.hasMore 
            onClicked: fetchHistory()
            loading: isLoading
        }
    }

    Component {
        id: dateHeader
        StatusListItem {
            property var modelData
            height: 40
            title: modelData !== undefined && !!modelData ? LocaleUtils.formatDate(modelData.timestamp * 1000, Locale.ShortFormat) : ""
            statusListItemTitle.color: Theme.palette.baseColor1
            color: Theme.palette.statusListItem.backgroundColor
            sensor.enabled: false
        }
    }

    Component {
        id: transactionDelegate
        TransactionDelegate {
            property bool modelDataValid: modelData !== undefined && !!modelData
            isIncoming: modelDataValid ? modelData.to === account.address: false
            cryptoValue: modelDataValid ? modelData.value : undefined
            fiatValue: modelDataValid ? RootStore.getFiatValue(cryptoValue.amount, symbol, RootStore.currentCurrency) : undefined
            networkIcon: modelDataValid ? RootStore.getNetworkIcon(modelData.chainId) : ""
            networkColor: modelDataValid ? RootStore.getNetworkColor(modelData.chainId) : ""
            networkName: modelDataValid ? RootStore.getNetworkShortName(modelData.chainId) : ""
            symbol: modelDataValid ? modelData.symbol : ""
            transferStatus: modelDataValid ? RootStore.hex2Dec(modelData.txStatus) : ""
            shortTimeStamp: modelDataValid ? LocaleUtils.formatTime(modelData.timestamp * 1000, Locale.ShortFormat) : ""
            savedAddressName: modelDataValid ? RootStore.getNameForSavedWalletAddress(modelData.to) : ""
            onClicked: launchTransactionDetail(modelData)
        }
    }

    Component {
        id: loadingImageComponent
        StatusLoadingIndicator {}
    }
}
