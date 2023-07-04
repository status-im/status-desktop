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
import "../stores"
import "../controls"

import AppLayouts.Wallet.stores 1.0 as WalletStores
import AppLayouts.Wallet.popups 1.0
import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.panels 1.0

ColumnLayout {
    id: root

    property var overview

    signal launchTransactionDetail(var transaction)

    QtObject {
        id: d
        readonly property bool isInitialLoading: RootStore.loadingHistoryTransactions && transactionListRoot.count === 0
        property var activityFiltersStore: WalletStores.ActivityFiltersStore{}
        readonly property int loadingSectionWidth: 56
        readonly property int topSectionMargin: 20
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
        visible: !d.isInitialLoading && !d.activityFiltersStore.filtersSet && transactionListRoot.count === 0
        font.pixelSize: Style.current.primaryTextFontSize
        text: qsTr("Activity for this account will appear here")
    }

    ActivityFilterPanel {
        id: filterComponent
        visible: !noTxs.visible && (!d.isInitialLoading || d.activityFiltersStore.filtersSet)
        Layout.fillWidth: true
        activityFilterStore: d.activityFiltersStore
        store: WalletStores.RootStore
        isLoading: d.isInitialLoading
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
                        } else if (currDate.getMonth() === timestampDate.getMonth()) {
                            return qsTr("Earlier this month")
                        } else if ((new Date(new Date().setDate(0))).getMonth() === timestampDate.getMonth()) {
                            return qsTr("Last month")
                        }
                        return timestampDate.toLocaleDateString(Qt.locale(), "MMM yyyy")
                    }
                }
            }

            delegate: transactionDelegate

            headerPositioning: ListView.OverlayHeader
            header: headerComp
            footer: footerComp

            ScrollBar.vertical: StatusScrollBar {}

            section.property: "date"
            // Adding some magic number to align the top headerComp with the top of the list.
            // TODO: have to be fixed properly and match the design
            topMargin: d.isInitialLoading ? 0 : -(2 * d.topSectionMargin + 9) // Top margin for first section. Section cannot have different sizes
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
                if (!footerItem || !RootStore.historyTransactions.hasMore)
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

        Separator {
            id: topListSeparator
            width: parent.width
            visible: !transactionListRoot.atYBeginning
        }
    }

    StatusMenu {
        id: delegateMenu

        hideDisabledItems: true

        property var transaction
        property var transactionDelegate

        function openMenu(delegate, mouse) {
            if (!delegate || !delegate.modelData)
                return

            delegateMenu.transactionDelegate = delegate
            delegateMenu.transaction = delegate.modelData
            repeatTransactionAction.enabled = !overview.isWatchOnlyAccount && delegate.modelData.txType === TransactionDelegate.Send
            popup(delegate, mouse.x, mouse.y)
        }

        onClosed: {
            delegateMenu.transaction = null
            delegateMenu.transactionDelegate = null
        }

        StatusAction {
            id: repeatTransactionAction
            text: qsTr("Repeat transaction")
            enabled: false
            icon.name: "rotate"
            onTriggered: {
                if (!delegateMenu.transaction)
                    return
                root.sendModal.open(delegateMenu.transaction.to)
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
            enabled: false
            text: qsTr("Filter by similar")
            icon.name: "filter"
            onTriggered: {
                // TODO apply filter
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
            onClicked: {
                if (mouse.button === Qt.RightButton) {
                    delegateMenu.openMenu(this, mouse, modelData)
                } else {
                    launchTransactionDetail(modelData)
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
            spacing: 12

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
                model: RootStore.historyTransactions.hasMore || d.isInitialLoading ? 10 : 0
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

    Component {
        id: headerComp

        Item {
            width: root.width
            height: dataUpdatedButton.implicitHeight

            StatusButton {
                id: dataUpdatedButton

                anchors.centerIn: parent

                text: qsTr("New transactions")

                visible: RootStore.newDataAvailable
                onClicked: RootStore.resetFilter()

                icon.name: "arrow-up"

                radius: 36
                textColor: Theme.palette.indirectColor1
                normalColor: Theme.palette.primaryColor1
                hoverColor: Theme.palette.miscColor1

                size: StatusBaseButton.Size.Tiny
            }
            z: 3
        }
    }
}
