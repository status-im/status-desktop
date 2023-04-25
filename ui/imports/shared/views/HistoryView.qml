import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

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

    property var overview
    property int pageSize: 20 // number of transactions per page

    signal launchTransactionDetail(var transaction)

    function fetchHistory() {
        if (!RootStore.isFetchingHistory(root.overview.mixedcaseAddress)) {
            d.isLoading = true
            RootStore.loadTransactionsForAccount(root.overview.mixedcaseAddress, pageSize)
        }
    }

    QtObject {
        id: d
        property bool isLoading: false
    }

    Connections {
        target: RootStore.history
        function onLoadingTrxHistoryChanged(isLoading: bool, address: string) {
            if (root.overview.mixedcaseAddress.toLowerCase() === address.toLowerCase()) {
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
                    return timestamp > 0 ? txModel.formatDate(timestamp * 1000) : (d.isLoading ? " " : "") //  not empty, because section will not be displayed when loading if empty
                }
            }
        }

        delegate: transactionDelegate

        footer: footerComp

        displaced: Transition { // TODO Remove animation when ordered fetching of transactions is implemented
            NumberAnimation { properties: "y"; duration: 250; easing.type: Easing.Linear; alwaysRunToEnd: true }
        }

        readonly property point lastVisibleItemPos: Qt.point(0, contentY + height - 1)
        property int lastVisibleIndex: indexAt(lastVisibleItemPos.x, lastVisibleItemPos.y)

        onCountChanged: {
            // Preserve last visible item in view when more items added at the end or
            // inbetween
            // TODO Remove this logic, when new activity design is implemented
            // and items are loaded in order
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

        // TODO Remove this logic, when new activity design is implemented
        // and items are loaded in order
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
            id: sectionDelegate

            readonly property bool isFirstSection: ListView.view.firstSection === section

            width: ListView.view.width
            height: isFirstSection || section.length > 1 ? 40 : 0 // 1 because we don't use empty for loading state
            visible: height > 0 // display always first section. Other sections when more items are being fetched must not be visible

            required property string section

            StatusTextWithLoadingState {
                id: sectionText

                anchors.verticalCenter: parent.verticalCenter
                text: loading ? "dummy" : parent.section // dummy text because loading component height depends on text height, and not visible with height == 0
                Binding on width {
                    when: sectionText.loading
                    value: 56
                    restoreMode: Binding.RestoreBindingOrValue
                }
                customColor: Theme.palette.baseColor1
                font.pixelSize: 15
                loading: { // First section must be loading when first item in the list is loading. Other sections are never visible until have date value
                    if (parent.ListView.view.count > 0) {
                        const firstItem = parent.ListView.view.itemAtIndex(0)
                        if (sectionDelegate.isFirstSection && firstItem && firstItem.loading) {
                            return true
                        }
                    }
                    return false
                }
            }
        }
        onAtYEndChanged: if(atYEnd && RootStore.historyTransactions.count > 0 && RootStore.historyTransactions.hasMore) fetchHistory()
    }

    Component {
        id: transactionDelegate
        TransactionDelegate {
            width: ListView.view.width
            modelData: model
            isIncoming: isModelDataValid ? modelData.to === root.overview.mixedcaseAddress: false
            currentCurrency: RootStore.currentCurrency
            cryptoValue: isModelDataValid ? modelData.value.amount : 0.0
            fiatValue: isModelDataValid ? RootStore.getFiatValue(cryptoValue, symbol, currentCurrency): 0.0
            networkIcon: isModelDataValid ? RootStore.getNetworkIcon(modelData.chainId) : ""
            networkColor: isModelDataValid ? RootStore.getNetworkColor(modelData.chainId) : ""
            networkName: isModelDataValid ? RootStore.getNetworkShortName(modelData.chainId) : ""
            symbol: isModelDataValid && !!modelData.symbol ? modelData.symbol : ""
            transferStatus: isModelDataValid ? RootStore.hex2Dec(modelData.txStatus) : ""
            shortTimeStamp: isModelDataValid ? LocaleUtils.formatTime(modelData.timestamp * 1000, Locale.ShortFormat) : ""
            savedAddressNameTo: isModelDataValid ? RootStore.getNameForSavedWalletAddress(modelData.to) : ""
            savedAddressNameFrom: isModelDataValid ? RootStore.getNameForSavedWalletAddress(modelData.from) : ""
            isSummary: true
            onClicked: launchTransactionDetail(modelData)
            loading: isModelDataValid ? modelData.loadingTransaction : false

            Component.onCompleted: {
                if (index == 0)
                    ListView.view.firstSection = date
            }
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
