import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import SortFilterProxyModel 0.2

import utils 1.0

import "../panels"
import "../popups"
import "../popups/send"
import "../stores"
import "../controls"

import AppLayouts.Wallet.stores 1.0 as WalletStores
import AppLayouts.Wallet.popups 1.0
import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.panels 1.0

ColumnLayout {
    id: root

    property var overview
    property bool showAllAccounts: false
    property var sendModal

    signal launchTransactionDetail(var transaction, int entryIndex)

    function resetView() {
        if (!!filterPanelLoader.item) {
            filterPanelLoader.item.resetView()
        }
    }

    onVisibleChanged: {
        if (!visible)
            return

        filterPanelLoader.active = true
        if (RootStore.transactionActivityStatus.isFilterDirty) {
            WalletStores.RootStore.currentActivityFiltersStore.applyAllFilters()
        }

        WalletStores.RootStore.currentActivityFiltersStore.updateCollectiblesModel()
        WalletStores.RootStore.currentActivityFiltersStore.updateRecipientsModel()
    }

    Connections {
        target: RootStore.transactionActivityStatus
        enabled: root.visible
        function onIsFilterDirtyChanged() {
            RootStore.updateTransactionFilter()
        }
        function onFilterChainsChanged() {
            WalletStores.RootStore.currentActivityFiltersStore.updateCollectiblesModel()
            WalletStores.RootStore.currentActivityFiltersStore.updateRecipientsModel()
        }
    }

    QtObject {
        id: d
        readonly property bool isInitialLoading: RootStore.loadingHistoryTransactions && transactionListRoot.count === 0

        readonly property int loadingSectionWidth: 56
        readonly property int topSectionMargin: 20

        property double lastRefreshTime
        readonly property int maxSecondsBetweenRefresh: 3
        function refreshData() {
            RootStore.resetFilter()
            d.lastRefreshTime = Date.now()
            newTransactions.visible = false
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

    ShapeRectangle {
        id: noTxs
        Layout.fillWidth: true
        Layout.preferredHeight: 42
        visible: !d.isInitialLoading && !WalletStores.RootStore.currentActivityFiltersStore.filtersSet && transactionListRoot.count === 0
        font.pixelSize: Style.current.primaryTextFontSize
        text: qsTr("Activity for this account will appear here")
    }

    Loader {
        id: filterPanelLoader
        active: false
        asynchronous: true
        Layout.fillWidth: true
        sourceComponent: ActivityFilterPanel {
            visible: d.isInitialLoading || transactionListRoot.count > 0 || WalletStores.RootStore.currentActivityFiltersStore.filtersSet
            activityFilterStore: WalletStores.RootStore.currentActivityFiltersStore
            store: WalletStores.RootStore
            hideNoResults: newTransactions.visible
            isLoading: d.isInitialLoading
        }
    }

    Item {
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: nonArchivalNodeError.visible || noTxs.visible ? Style.current.padding : 0
        Layout.bottomMargin: Style.current.padding
        Layout.fillWidth: true
        Layout.fillHeight: true

        Rectangle { // Shadow behind delegates when scrolling
            anchors.top: topListSeparator.bottom
            width: parent.width
            height: 4
            color: Style.current.separator
            visible: topListSeparator.visible
        }

        StatusListView {
            id: transactionListRoot
            objectName: "walletAccountTransactionList"
            anchors.fill: parent

            model: SortFilterProxyModel {
                id: txModel

                sourceModel: RootStore.historyTransactions

                // LocaleUtils is not accessable from inside expression, but local function works
                property var daysTo: (d1, d2) => LocaleUtils.daysTo(d1, d2)
                property var daysBetween: (d1, d2) => LocaleUtils.daysBetween(d1, d2)
                property var getFirstDayOfTheCurrentWeek: () => LocaleUtils.getFirstDayOfTheCurrentWeek()
                proxyRoles: ExpressionRole {
                    name: "date"
                    expression: {
                        if (model.activityEntry.timestamp === 0)
                            return ""
                        const currDate = new Date()
                        const timestampDate = new Date(model.activityEntry.timestamp * 1000)
                        const daysDiff = txModel.daysBetween(currDate, timestampDate)
                        const daysToBeginingOfThisWeek = txModel.daysTo(timestampDate, txModel.getFirstDayOfTheCurrentWeek())

                        if (daysDiff < 1) {
                            return qsTr("Today")
                        } else if (daysDiff < 2) {
                            return qsTr("Yesterday")
                        } else if (daysToBeginingOfThisWeek >= 0) {
                            return qsTr("Earlier this week")
                        } else if (daysToBeginingOfThisWeek > -7) {
                            return qsTr("Last week")
                        } else if (currDate.getMonth() === timestampDate.getMonth() && currDate.getYear() === timestampDate.getYear()) {
                            return qsTr("Earlier this month")
                        }

                        const previousMonthDate = (new Date(new Date().setDate(0)))
                        // Special case for the end of the year
                        if ((timestampDate.getMonth() === previousMonthDate.getMonth() && timestampDate.getYear() === previousMonthDate.getYear())
                            || (previousMonthDate.getMonth() === 11 && timestampDate.getMonth() === 0 && Math.abs(timestampDate.getYear() - previousMonthDate.getYear()) === 1))
                        {
                            return qsTr("Last month")
                        }

                        return timestampDate.toLocaleDateString(Qt.locale(), "MMM yyyy")
                    }
                }
            }

            delegate: transactionDelegate

            headerPositioning: ListView.OverlayHeader
            footer: footerComp

            ScrollBar.vertical: StatusScrollBar {}

            section.property: "date"
            topMargin: d.isInitialLoading ? 0 : -d.topSectionMargin // Top margin for first section. Section cannot have different sizes
            section.delegate: ColumnLayout {
                id: sectionDelegate

                width: ListView.view.width
                height: 58
                spacing: 0

                required property string section

                Separator {
                    Layout.fillWidth: true
                    Layout.topMargin: d.topSectionMargin
                    implicitHeight: 1
                }

                StatusBaseText {
                    id: sectionText
                    Layout.alignment: Qt.AlignBottom
                    leftPadding: Style.current.padding
                    bottomPadding: Style.current.halfPadding
                    text: parent.section
                    font.pixelSize: 13
                    verticalAlignment: Qt.AlignBottom
                }
            }

            visibleArea.onYPositionChanged: tryFetchMoreTransactions()

            Connections {
                target: RootStore
                function onLoadingHistoryTransactionsChanged() {
                    // Calling timer instead directly to not cause binding loop
                    if (!RootStore.loadingHistoryTransactions)
                        fetchMoreTimer.start()
                }
            }

            function tryFetchMoreTransactions() {
                if (d.isInitialLoading || !footerItem || !RootStore.historyTransactions.hasMore)
                    return
                const footerYPosition = footerItem.height / contentHeight
                if (footerYPosition >= 1.0) {
                    return
                }

                // On startup, first loaded ListView will have heightRatio equal 0
                if (footerYPosition + visibleArea.yPosition + visibleArea.heightRatio > 1.0) {
                    RootStore.fetchMoreTransactions()
                }
            }

            Timer {
                id: fetchMoreTimer
                interval: 1
                onTriggered: transactionListRoot.tryFetchMoreTransactions()
            }
        }

        StatusButton {
            id: newTransactions
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Style.current.halfPadding

            text: qsTr("New transactions")

            visible: false
            onClicked: d.refreshData()

            icon.name: "arrow-up"

            radius: 36
            type: StatusButton.Primary
            size: StatusBaseButton.Size.Tiny
        }

        Separator {
            id: topListSeparator
            width: parent.width
            visible: !transactionListRoot.atYBeginning
        }


        Connections {
            target: RootStore

            function onNewDataAvailableChanged() {
                if (!d.lastRefreshTime || ((Date.now() - d.lastRefreshTime) > (1000 * d.maxSecondsBetweenRefresh))) {
                    // Show `New transactions` button only when filter is applied
                    if (!WalletStores.RootStore.currentActivityFiltersStore.filtersSet) {
                        d.refreshData()
                        return
                    }

                    newTransactions.visible = RootStore.newDataAvailable
                    return
                }

                if (showRefreshButtonTimer.running) {
                    if (!RootStore.newDataAvailable) {
                        showRefreshButtonTimer.stop()
                        newTransactions.visible = false
                    }
                } else if(RootStore.newDataAvailable) {
                    showRefreshButtonTimer.start()
                }
            }
        }

        Timer {
            id: showRefreshButtonTimer

            interval: 2000
            running: false
            repeat: false
            onTriggered: newTransactions.visible = RootStore.newDataAvailable
        }
    }

    StatusMenu {
        id: delegateMenu

        hideDisabledItems: true

        property var transaction
        property var transactionDelegate

        function openMenu(delegate, mouse, data) {
            if (!delegate || !data)
                return

            delegateMenu.transactionDelegate = delegate
            delegateMenu.transaction = data
            popup(delegate, mouse.x, mouse.y)
        }

        onClosed: {
            delegateMenu.transaction = null
            delegateMenu.transactionDelegate = null
        }

        StatusAction {
            id: repeatTransactionAction

            text: qsTr("Repeat transaction")
            icon.name: "rotate"

            property alias tx: delegateMenu.transaction

            enabled: {
                if (!overview.isWatchOnlyAccount && !tx)
                    return false
                return WalletStores.RootStore.isTxRepeatable(tx)
            }

            onTriggered: {
                if (!tx)
                    return
                let asset = WalletStores.RootStore.getAssetForSendTx(tx)

                let req = Helpers.lookupAddressesForSendModal(tx.sender, tx.recipient, asset, tx.isNFT, tx.amount)

                root.sendModal.preSelectedAccount = req.preSelectedAccount
                root.sendModal.preSelectedRecipient = req.preSelectedRecipient
                root.sendModal.preSelectedRecipientType = req.preSelectedRecipientType
                root.sendModal.preSelectedHolding = req.preSelectedHolding
                root.sendModal.preSelectedHoldingID = req.preSelectedHoldingID
                root.sendModal.preSelectedHoldingType = req.preSelectedHoldingType
                root.sendModal.preSelectedSendType = req.preSelectedSendType
                root.sendModal.preDefinedAmountToSend = req.preDefinedAmountToSend
                root.sendModal.onlyAssets = false
                root.sendModal.open()
            }
        }
        StatusSuccessAction {
            text: qsTr("Copy details")
            successText: qsTr("Details copied")
            icon.name: "copy"
            onTriggered: {
                if (!delegateMenu.transactionDelegate)
                    return
                RootStore.copyToClipboard(delegateMenu.transactionDelegate.getDetailsString())
            }
        }
        StatusMenuSeparator {
            visible: filterAction.enabled
        }
        StatusAction {
            id: filterAction
            text: qsTr("Filter by similar")
            icon.name: "filter"
            onTriggered: {
                const store = WalletStores.RootStore.currentActivityFiltersStore
                const tx = delegateMenu.transaction

                store.autoUpdateFilter = false
                store.resetAllFilters()

                const currentAddress = overview.mixedcaseAddress.toUpperCase()

                store.toggleType(tx.txType)
                // Contract deployment has always ETH symbol. Symbol doesn't affect this type
                if (tx.txType !== Constants.TransactionType.ContractDeployment) {
                    const symbol = tx.symbol
                    if (!!symbol)
                        store.toggleToken(symbol)
                    const inSymbol = tx.inSymbol
                    if (!!inSymbol && inSymbol !== symbol)
                        store.toggleToken(inSymbol)
                }
                if (showAllAccounts || tx.txType !== Constants.TransactionType.Bridge) {
                    const recipient = tx.recipient.toUpperCase()
                    if (!!recipient && recipient !== currentAddress && !/0X0+$/.test(recipient))
                        store.toggleRecents(recipient)
                }
                if (tx.isNFT) {
                    const uid = store.collectiblesList.getUidForData(tx.tokenID, tx.tokenAddress, tx.chainId)
                    if (!!uid)
                        store.toggleCollectibles(uid)
                }

                store.autoUpdateFilter = true
                store.applyAllFilters()
            }
        }
    }

    Component {
        id: transactionDelegate
        TransactionDelegate {
            required property var model
            required property int index
            width: ListView.view.width
            modelData: model.activityEntry
            timeStampText: isModelDataValid ? LocaleUtils.formatRelativeTimestamp(modelData.timestamp * 1000, true) : ""
            rootStore: RootStore
            walletRootStore: WalletStores.RootStore
            showAllAccounts: root.showAllAccounts
            onClicked: {
                if (mouse.button === Qt.RightButton) {
                    delegateMenu.openMenu(this, mouse, modelData)
                } else {
                    launchTransactionDetail(modelData, index)
                }
            }
        }
    }

    Component {
        id: footerComp
        ColumnLayout {
            id: footerColumn
            readonly property bool allActivityLoaded: !RootStore.historyTransactions.hasMore && transactionListRoot.count !== 0
            width: root.width
            spacing: d.isInitialLoading ? 6 : 12

            Separator {
                Layout.fillWidth: true
                Layout.topMargin: Style.current.halfPadding
                visible: d.isInitialLoading
            }

            StatusTextWithLoadingState {
                Layout.alignment: Qt.AlignLeft
                Layout.leftMargin: Style.current.padding
                text: "01.01.2000"
                width: d.loadingSectionWidth
                font.pixelSize: 15
                loading: visible
                visible: d.isInitialLoading
            }

            Repeater {
                model: {
                    if (!root.visible)
                        return 0
                    if (!noTxs.visible) {
                        const delegateHeight = 64 + footerColumn.spacing
                        if (d.isInitialLoading) {
                            return Math.floor(transactionListRoot.height / delegateHeight)
                        } else if (RootStore.historyTransactions.hasMore) {
                            return Math.max(3, Math.floor(transactionListRoot.height / delegateHeight) - 3)
                        }
                    }
                    return 0
                }
                TransactionDelegate {
                    Layout.fillWidth: true
                    rootStore: RootStore
                    walletRootStore: WalletStores.RootStore
                    loading: true
                }
            }

            Separator {
                Layout.topMargin: Style.current.bigPadding
                Layout.fillWidth: true
                visible: footerColumn.allActivityLoaded
            }
            StatusBaseText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("You have reached the beginning of the activity for this account")
                font.pixelSize: 13
                color: Theme.palette.baseColor1
                visible: footerColumn.allActivityLoaded
                horizontalAlignment: Text.AlignHCenter
            }
            StatusButton {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Back to most recent transaction")
                visible: footerColumn.allActivityLoaded && transactionListRoot.contentHeight > transactionListRoot.height
                onClicked: transactionListRoot.positionViewAtBeginning()
            }
        }
    }
}
