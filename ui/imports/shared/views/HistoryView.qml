import QtQuick 2.13
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import SortFilterProxyModel 0.2

import utils 1.0

import "../panels"
import "../popups"
import "../stores"
import "../controls"

ColumnLayout {
    id: root

    property var account
    property int pageSize: 20 // number of transactions per page

    signal launchTransactionDetail(var transaction)

    function fetchHistory() {
        if (!RootStore.isFetchingHistory(root.account.address)) {
            d.isLoading = true
            RootStore.loadTransactionsForAccount(root.account.address, pageSize)
        }
    }

    QtObject {
        id: d
        property bool isLoading: false
    }

    Connections {
        target: RootStore.history
        function onLoadingTrxHistoryChanged(isLoading: bool, address: string) {
            if (root.account.address.toLowerCase() === address.toLowerCase()) {
                d.isLoading = isLoading
            }
        }
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
        visible: !d.isLoading && transactionListRoot.count === 0
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

        property string firstSection

        model: SortFilterProxyModel {
            id: txModel

            sourceModel: RootStore.historyTransactions

            // LocaleUtils is not accessable from inside expression, but local function works
            property var formatDate: (ms) => LocaleUtils.formatDate(ms, Locale.ShortFormat)
            sorters: RoleSorter {
                roleName: "timestamp"
                sortOrder: Qt.DescendingOrder
            }
            proxyRoles: ExpressionRole {
                name: "date"
                expression: {
                    return timestamp > 0 ? txModel.formatDate(timestamp * 1000) : ""
                }
            }
        }

        delegate: Loader {
            width: ListView.view.width
            sourceComponent: transactionDelegate
            onLoaded:  {
                item.modelData = model

                if (index == 0)
                    ListView.view.firstSection = date
            }
        }
        footer: footerComp

        displaced: Transition {
            NumberAnimation { properties: "y"; duration: 250; easing.type: Easing.Linear; alwaysRunToEnd: true }
        }

        readonly property point lastVisibleItemPos: Qt.point(0, contentY + height - 1)
        property int lastVisibleIndex: indexAt(lastVisibleItemPos.x, lastVisibleItemPos.y)

        onCountChanged: {
            const lastVisibleItem = itemAtIndex(lastVisibleIndex)
            const newItem = itemAt(lastVisibleItemPos.x, lastVisibleItemPos.y)
            const lastVisibleItemY = lastVisibleItem ? lastVisibleItem.y : -1
            if (newItem) {
                if (newItem.y < lastVisibleItemY) { // item inserted higher than last visible
                    lastVisibleIndex = indexAt(lastVisibleItemPos.x, lastVisibleItemPos.y)
                }
            }
        }
        currentIndex: 0

        property bool userScrolled: false

        onMovingVerticallyChanged: {
            if (!userScrolled) {
                userScrolled = true
                currentIndex = Qt.binding(() => lastVisibleIndex >= 0 ? lastVisibleIndex : (count - 1))
            }

            lastVisibleIndex = indexAt(lastVisibleItemPos.x, lastVisibleItemPos.y)
        }

        ScrollBar.vertical: StatusScrollBar {}

        section.property: "date"
        section.delegate: Item {
            width: ListView.view.width
            height: ListView.view.firstSection === section || section.length > 0 ? 40 : 0
            visible: height > 0

            required property string section

            StatusBaseText {
                anchors.verticalCenter: parent.verticalCenter
                text: parent.section
                color: Theme.palette.baseColor1
                font.pixelSize: 15
            }
        }
        onAtYEndChanged: if (atYEnd && RootStore.historyTransactions.hasMore) fetchHistory()
    }

    Component {
        id: transactionDelegate
        TransactionDelegate {
            property bool modelDataValid: !!modelData
            isIncoming: modelDataValid ? modelData.to === account.address: false
            currentCurrency: RootStore.currentCurrency
            cryptoValue: modelDataValid ? modelData.value.amount : 0.0
            fiatValue: modelDataValid ? RootStore.getFiatValue(cryptoValue, symbol, currentCurrency): 0.0
            networkIcon: modelDataValid ? RootStore.getNetworkIcon(modelData.chainId) : ""
            networkColor: modelDataValid ? RootStore.getNetworkColor(modelData.chainId) : ""
            networkName: modelDataValid ? RootStore.getNetworkShortName(modelData.chainId) : ""
            symbol: modelDataValid && !!modelData.symbol ? modelData.symbol : ""
            transferStatus: modelDataValid ? RootStore.hex2Dec(modelData.txStatus) : ""
            shortTimeStamp: modelDataValid ? LocaleUtils.formatTime(modelData.timestamp * 1000, Locale.ShortFormat) : ""
            savedAddressNameTo: modelDataValid ? RootStore.getNameForSavedWalletAddress(modelData.to) : ""
            savedAddressNameFrom: modelDataValid ? RootStore.getNameForSavedWalletAddress(modelData.from) : ""
            isSummary: true
            onClicked: launchTransactionDetail(modelData)
            loading: modelDataValid ? modelData.loadingTransaction : false
        }
    }

    Component {
        id: footerComp
        ColumnLayout {
            width: root.width
            visible: !RootStore.historyTransactions.hasMore && transactionListRoot.count !== 0
            spacing: 12
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Style.current.padding
                Layout.preferredWidth: parent.width - 100
                Layout.preferredHeight: 1
                color: Theme.palette.directColor8
                visible: !RootStore.historyTransactions.hasMore
            }
            StatusBaseText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("You have reached the beginning of the activity for this account")
                font.pixelSize: 13
                color: Theme.palette.baseColor1
                visible: !RootStore.historyTransactions.hasMore
                horizontalAlignment: Text.AlignHCenter
            }
            StatusButton {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Back to most recent transaction")
                visible: !RootStore.historyTransactions.hasMore
                onClicked: transactionListRoot.positionViewAtBeginning()
            }
        }
    }
}
