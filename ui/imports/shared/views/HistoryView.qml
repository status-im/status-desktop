import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
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

import AppLayouts.Communities.stores 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStores
import AppLayouts.Wallet.popups 1.0
import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.panels 1.0

ColumnLayout {
    id: root

    property var overview

    property WalletStores.RootStore walletRootStore
    property CommunitiesStore communitiesStore
    property CurrenciesStore currencyStore
    property bool showAllAccounts: false
    property bool displayValues: true
    property var sendModal
    property bool filterVisible
    property bool disableShadowOnScroll: false
    property bool hideVerticalScrollbar: false
    property int firstItemOffset: 0

    property real yPosition: transactionListRoot.visibleArea.yPosition * transactionListRoot.contentHeight

    signal launchTransactionDetail(string txID)

    function resetView() {
        if (!!filterPanelLoader.item) {
            filterPanelLoader.item.resetView()
        }
    }

    onVisibleChanged: {
        d.openTxDetailsHash = ""
    }

    Component.onCompleted: {
        if (root.walletRootStore.transactionActivityStatus.isFilterDirty) {
            root.walletRootStore.currentActivityFiltersStore.applyAllFilters()
        }

        root.walletRootStore.currentActivityFiltersStore.updateCollectiblesModel()
        root.walletRootStore.currentActivityFiltersStore.updateRecipientsModel()
    }

    Connections {
        target: root.walletRootStore.transactionActivityStatus
        enabled: root.visible
        function onIsFilterDirtyChanged() {
            root.walletRootStore.updateTransactionFilterIfDirty()
        }
        function onFilterChainsChanged() {
            root.walletRootStore.currentActivityFiltersStore.updateCollectiblesModel()
            root.walletRootStore.currentActivityFiltersStore.updateRecipientsModel()
        }
    }

    Connections {
        target: root.walletRootStore.currentActivityFiltersStore
        enabled: root.visible
        function onDisplayTxDetails(txHash) {
            if (!d.openTxDetails(txHash)) {
                d.openTxDetailsHash = txHash
            }
        }
    }

    QtObject {
        id: d
        readonly property bool isInitialLoading: root.walletRootStore.loadingHistoryTransactions && transactionListRoot.count === 0

        readonly property int loadingSectionWidth: 56

        property bool firstSectionHeaderLoaded: false

        readonly property int maxSecondsBetweenRefresh: 3

        property string openTxDetailsHash

        function openTxDetails(txID) {
            // Prevent opening details when loading, that will invalidate the model data
            if (root.walletRootStore.loadingHistoryTransactions) {
                return false
            }

            root.launchTransactionDetail(txID)
            return true
        }
    }

    InformationTag {
        id: betaTag
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: root.firstItemOffset
        Layout.preferredHeight: 56
        visible: root.firstItemOffset === 0 // visible only in the main wallet view
        spacing: Theme.halfPadding
        backgroundColor: Theme.palette.primaryColor3
        bgRadius: Theme.radius
        bgBorderColor: Theme.palette.primaryColor2
        tagPrimaryLabel.textFormat: Text.RichText
        tagPrimaryLabel.font.pixelSize: Theme.additionalTextSize
        tagPrimaryLabel.text: qsTr("Activity is in beta. If transactions are missing, check %1, %2, or %3.")
            .arg(Utils.getStyledLink("Etherscan", "https://etherscan.io/", tagPrimaryLabel.hoveredLink))
            .arg(Utils.getStyledLink("OP Explorer", "https://optimistic.etherscan.io/", tagPrimaryLabel.hoveredLink))
            .arg(Utils.getStyledLink("Arbiscan", "https://arbiscan.io/", tagPrimaryLabel.hoveredLink))
        tagPrimaryLabel.onLinkActivated: (link) => {
            const explorerUrl = root.walletRootStore.showAllAccounts ? link
                                                                       : "%1/%2/%3".arg(link).arg(Constants.networkExplorerLinks.addressPath).arg(root.walletRootStore.selectedAddress)
            Global.openLinkWithConfirmation(explorerUrl, SQUtils.StringUtils.extractDomainFromLink(explorerUrl))
        }
        asset {
            name: "warning"
            width: 20
            height: 20
            color: Theme.palette.primaryColor1
        }
        HoverHandler {
            cursorShape: hovered && !!parent.tagPrimaryLabel.hoveredLink ? Qt.PointingHandCursor : undefined
        }
    }

    StyledText {
        id: nonArchivalNodeError
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: root.firstItemOffset
        visible: root.walletRootStore.isNonArchivalNode
        text: qsTr("Status Desktop is connected to a non-archival node. Transaction history may be incomplete.")
        font.pixelSize: Theme.primaryTextFontSize
        color: Theme.palette.dangerColor1
        wrapMode: Text.WordWrap
    }

    ShapeRectangle {
        id: noTxs
        Layout.fillWidth: true
        Layout.preferredHeight: 42
        Layout.topMargin: !nonArchivalNodeError.visible? root.firstItemOffset : 0
        visible: !d.isInitialLoading && !root.walletRootStore.currentActivityFiltersStore.filtersSet && transactionListRoot.count === 0
        font.pixelSize: Theme.primaryTextFontSize
        text: qsTr("Activity for this account will appear here")
    }

    Loader {
        id: filterPanelLoader
        active: root.filterVisible && (d.isInitialLoading || transactionListRoot.count > 0 || root.walletRootStore.currentActivityFiltersStore.filtersSet)
        visible: active && !noTxs.visible
        asynchronous: true
        Layout.fillWidth: true
        sourceComponent: ActivityFilterPanel {
            activityFilterStore: root.walletRootStore.currentActivityFiltersStore
            store: root.walletRootStore
            hideNoResults: newTransactions.visible
            isLoading: d.isInitialLoading
        }
    }

    Item {
        id: transactionListWrapper
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: nonArchivalNodeError.visible || noTxs.visible ? Theme.padding : 0
        Layout.fillWidth: true
        Layout.fillHeight: true

        Rectangle { // Shadow behind delegates when scrolling
            anchors.top: parent.top
            width: parent.width
            height: 4
            color: Theme.palette.separator
            visible: !root.disableShadowOnScroll && !transactionListRoot.atYBeginning
        }

        StatusListView {
            id: transactionListRoot
            objectName: "walletAccountTransactionList"
            anchors.fill: parent

            onCountChanged: {
                if (!!d.openTxDetailsHash && root.visible) {
                    if (d.openTxDetails(d.openTxDetailsHash)) {
                        d.openTxDetailsHash = ""
                    } else {
                        root.walletRootStore.fetchMoreTransactions()
                    }
                }
            }

            model: SortFilterProxyModel {
                id: txModel

                sourceModel: root.walletRootStore.historyTransactions

                // LocaleUtils is not accessable from inside expression, but local function works
                property var daysTo: (d1, d2) => LocaleUtils.daysTo(d1, d2)
                property var daysBetween: (d1, d2) => LocaleUtils.daysBetween(d1, d2)
                property var getFirstDayOfTheCurrentWeek: () => LocaleUtils.getFirstDayOfTheCurrentWeek()
                proxyRoles: ExpressionRole {
                    name: "date"
                    expression: {
                        if (!model.activityEntry || model.activityEntry.timestamp === 0)
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

            delegate: transactionDelegateComponent

            headerPositioning: ListView.OverlayHeader
            footer: footerComp

            ScrollBar.vertical: StatusScrollBar {
                policy: root.hideVerticalScrollbar? ScrollBar.AlwaysOff : ScrollBar.AsNeeded
            }

            visibleArea.onYPositionChanged: {
                tryFetchMoreTransactions()
            }

            Connections {
                target: root.walletRootStore

                function onLoadingHistoryTransactionsChanged() {
                    // Calling timer instead directly to not cause binding loop
                    if (!root.walletRootStore.loadingHistoryTransactions)
                        fetchMoreTimer.start()
                }
            }

            function tryFetchMoreTransactions() {
                if (d.isInitialLoading || !footerItem || !root.walletRootStore.historyTransactions.hasMore)
                    return
                const footerYPosition = footerItem.height / contentHeight
                if (footerYPosition >= 1.0) {
                    return
                }

                // On startup, first loaded ListView will have heightRatio equal 0
                if (footerYPosition + visibleArea.yPosition + visibleArea.heightRatio > 1.0) {
                    root.walletRootStore.fetchMoreTransactions()
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
            anchors.topMargin: Theme.halfPadding

            text: qsTr("New transactions")

            visible: root.walletRootStore.newDataAvailable && !root.walletRootStore.loadingHistoryTransactions
            onClicked: root.walletRootStore.resetActivityData()

            icon.name: "arrow-up"

            radius: 36
            type: StatusButton.Primary
            size: StatusBaseButton.Size.Tiny
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
                return root.walletRootStore.isTxRepeatable(tx)
            }

            onTriggered: {
                if (!tx)
                    return
                let asset = root.walletRootStore.getAssetForSendTx(tx)

                const req = Helpers.lookupAddressesForSendModal(root.walletRootStore.accounts,
                                                              root.walletRootStore.savedAddresses,
                                                              tx.sender,
                                                              tx.recipient,
                                                              asset,
                                                              tx.isNFT,
                                                              tx.amount,
                                                              tx.chainId)

                root.sendModal.preSelectedAccountAddress = req.preSelectedAccount.address
                root.sendModal.preSelectedRecipient = req.preSelectedRecipient
                root.sendModal.preSelectedRecipientType = req.preSelectedRecipientType
                root.sendModal.preSelectedHoldingID = req.preSelectedHoldingID
                root.sendModal.preSelectedHoldingType = req.preSelectedHoldingType
                root.sendModal.preSelectedSendType = req.preSelectedSendType
                root.sendModal.preDefinedAmountToSend = req.preDefinedAmountToSend
                root.sendModal.preSelectedChainId = req.preSelectedChainId
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
                root.walletRootStore.addressWasShown(delegateMenu.transaction.sender)
                if (delegateMenu.transaction.sender !== delegateMenu.transaction.recipient) {
                    root.walletRootStore.addressWasShown(delegateMenu.transaction.recipient)
                }

                root.walletRootStore.fetchTxDetails(delegateMenu.transaction.id)
                let detailsObj = root.walletRootStore.getTxDetails()
                let detailsString = delegateMenu.transactionDelegate.getDetailsString(detailsObj)
                ClipboardUtils.setText(detailsString)
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
                const store = root.walletRootStore.currentActivityFiltersStore
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
        id: transactionDelegateComponent
        ColumnLayout {
            id: transactionDelegate

            required property var model
            required property int index

            readonly property bool displaySectionHeader: index === 0 || model.date !== txModel.get(index - 1).date
            readonly property bool displaySectionFooter: index === txModel.count-1  || model.date !== txModel.get(index + 1).date

            width: ListView.view.width
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: root.firstItemOffset
                visible: transactionDelegate.index === 0 && root.firstItemOffset > 0
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height
                visible: transactionDelegate.displaySectionHeader
                color: Theme.palette.statusModal.backgroundColor

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: parent.width
                    spacing: Theme.halfPadding

                    Separator {
                        Layout.fillWidth: true
                        implicitHeight: 1
                    }

                    StatusBaseText {
                        leftPadding: Theme.padding
                        bottomPadding: Theme.halfPadding
                        text: transactionDelegate.model.date
                        font.pixelSize: 13
                    }
                }
            }

            TransactionDelegate {
                Layout.fillWidth: true
                modelData: transactionDelegate.model.activityEntry
                timeStampText: isModelDataValid ? LocaleUtils.formatRelativeTimestamp(modelData.timestamp * 1000, true) : ""
                flatNetworks: root.walletRootStore.flatNetworks
                currenciesStore: root.currencyStore
                walletRootStore: root.walletRootStore
                showAllAccounts: root.showAllAccounts
                displayValues: root.displayValues
                community: isModelDataValid && !!communityId && !!root.communitiesStore ? root.communitiesStore.getCommunityDetailsAsJson(communityId) : null
                onClicked: {
                    if (mouse.button === Qt.RightButton) {
                        delegateMenu.openMenu(this, mouse, modelData)
                    } else {
                        launchTransactionDetail(modelData.id)
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                visible: transactionDelegate.displaySectionFooter
                color: Theme.palette.statusModal.backgroundColor
            }
        }
    }

    Component {
        id: footerComp
        ColumnLayout {
            id: footerColumn
            readonly property bool allActivityLoaded: !root.walletRootStore.historyTransactions.hasMore && transactionListRoot.count !== 0
            width: root.width
            spacing: d.isInitialLoading ? 6 : 12

            Separator {
                Layout.fillWidth: true
                Layout.topMargin: Theme.halfPadding
                visible: d.isInitialLoading
            }

            StatusTextWithLoadingState {
                Layout.alignment: Qt.AlignLeft
                Layout.leftMargin: Theme.padding
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
                        } else if (root.walletRootStore.historyTransactions.hasMore) {
                            return Math.max(3, Math.floor(transactionListRoot.height / delegateHeight) - 3)
                        }
                    }
                    return 0
                }
                TransactionDelegate {
                    Layout.fillWidth: true

                    flatNetworks: root.walletRootStore.flatNetworks
                    currenciesStore: root.currencyStore
                    walletRootStore: root.walletRootStore
                    loading: true
                }
            }

            Separator {
                Layout.topMargin: Theme.bigPadding
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

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.halfPadding
            }
        }
    }
}
