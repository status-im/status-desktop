import QtQuick 2.13
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

import utils 1.0

import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import shared.panels 1.0
import "../popups"
import "../stores"
import "../controls"

Item {
    id: historyView

    property int pageSize: 20 // number of transactions per page

    function fetchHistory() {
        if (RootStore.isFetchingHistory()) {
            loadingImg.active = true
        } else {
            RootStore.loadTransactionsForAccount(pageSize)
        }
    }

    Loader {
        id: loadingImg
        active: false
        sourceComponent: loadingImageComponent
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.top: parent.top
    }

    Component {
        id: loadingImageComponent
        StatusLoadingIndicator {}
    }

    Connections {
        target: RootStore.history
        onLoadingTrxHistoryChanged: {
            if (RootStore.currentAccount.address.toLowerCase() === address.toLowerCase()) {
                loadingImg.active = isLoading
            }
        }
    }

    StyledText {
        id: nonArchivalNodeError
        visible: RootStore.isNonArchivalNode
        height: visible ? implicitHeight : 0
        anchors.top: parent.top
        //% "Status Desktop is connected to a non-archival node. Transaction history may be incomplete."
        text: qsTrId("status-desktop-is-connected-to-a-non-archival-node--transaction-history-may-be-incomplete-")
        font.pixelSize: Style.current.primaryTextFontSize
        color: Style.current.danger
    }

    StyledText {
        id: noTxs
        anchors.top: nonArchivalNodeError.bottom
        visible: transactionListRoot.count === 0
        height: visible ? implicitHeight : 0
        //% "No transactions found"
        text: qsTrId("no-transactions-found")
        font.pixelSize: Style.current.primaryTextFontSize
    }

    ListView {
        id: transactionListRoot
        anchors.top: noTxs.bottom
        anchors.topMargin: Style.current.padding
        anchors.bottom: loadMoreButton.top
        anchors.bottomMargin: Style.current.padding
        width: parent.width
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        model: RootStore.historyTransactions
        delegate: TransactionDelegate {
            tokens: RootStore.tokens
            locale: RootStore.locale
            currentAccountAddress: RootStore.currentAccount.address
            ethValue: RootStore.hex2Eth(value)
            onLaunchTransactionModal: {
                transactionModal.transaction = model
                transactionModal.open()
            }
        }

        ScrollBar.vertical: ScrollBar {
            id: scrollBar
        }

        onCountChanged: {
            if (loadMoreButton.loadedMore)
                transactionListRoot.positionViewAtEnd();
        }
    }

    StatusButton {
        id: loadMoreButton
        //% "Load More"
        text: qsTrId("load-more")
        // TODO: handle case when requested limit === transaction count -- there
        // is currently no way to know that there are no more results
        enabled: !loadingImg.active && RootStore.historyTransactions.hasMore
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        property bool loadedMore: false

        onClicked: {
            fetchHistory()
            loadMoreButton.loadedMore = true
        }
    }

    TransactionModal {
        id: transactionModal
    }
}
