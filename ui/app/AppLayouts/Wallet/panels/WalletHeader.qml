import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Popups 0.1

import QtModelsToolkit 1.0
import SortFilterProxyModel 0.2

import shared.stores 1.0 as SharedStores

import AppLayouts.Wallet.stores 1.0 as WalletStores
import AppLayouts.Wallet.services.dapps 1.0

import utils 1.0

import "../controls"

Item {
    id: root

    required property SharedStores.NetworksStore networksStore
    property SharedStores.NetworkConnectionStore networkConnectionStore
    property WalletStores.RootStore walletStore

    property var overview
    property int loginType // RootStore.loginType -> Constants.LoginType enum

    property alias headerButton: headerButton
    property alias networkFilter: networkFilter

    property bool dAppsEnabled: true
    property bool dAppsVisible: true
    property var dAppsModel

    signal dappListRequested()
    signal dappConnectRequested()
    signal dappDisconnectRequested(string dappUrl)
    signal manageNetworksRequested()

    implicitHeight: 88

    GridLayout {
        width: parent.width
        columns: 2
        rowSpacing: 0

        // account + balance
        RowLayout {
            spacing: Theme.halfPadding
            StatusBaseText {
                objectName: "walletHeaderTitle"
                Layout.alignment: Qt.AlignVCenter
                verticalAlignment: Text.AlignVCenter
                color: {
                    if (root.walletStore.showSavedAddresses)
                        return Theme.palette.directColor1

                    return overview.isAllAccounts ? Theme.palette.directColor5 : Utils.getColorForId(overview.colorId)
                }
                lineHeightMode: Text.FixedHeight
                lineHeight: 38
                font.bold: true
                font.pixelSize: 28
                text: {
                    if (root.walletStore.showSavedAddresses)
                        return qsTr("Saved addresses")

                    return overview.isAllAccounts ? qsTr("All accounts") : overview.name
                }
            }
            StatusEmoji {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                emojiId: !!root.overview && StatusQUtils.Emoji.iconId(root.overview.emoji ?? "", StatusQUtils.Emoji.size.big) || ""
                visible: !root.walletStore.showSavedAddresses &&
                         !!root.overview && !root.overview.isAllAccounts
            }
        }

        RowLayout {
            spacing: 16
            Layout.alignment: Qt.AlignTrailing
            Layout.topMargin: 5
            Row {
                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                Layout.preferredHeight: 38
                spacing: 8

                StatusButton {
                    id: reloadButton
                    size: StatusBaseButton.Size.Tiny
                    height: parent.height
                    width: height
                    borderColor: Theme.palette.directColor7
                    borderWidth: 1

                    normalColor: Theme.palette.transparent
                    hoverColor: Theme.palette.baseColor2

                    icon.name: "refresh"
                    icon.color: {
                        if (!interactive) {
                            return Theme.palette.baseColor1;
                        }
                        if (hovered) {
                            return Theme.palette.directColor1;
                        }

                        return Theme.palette.baseColor1;
                    }
                    asset.mirror: true

                    loading: root.walletStore.isAccountTokensReloading
                    interactive: !loading && !throttleTimer.running
                    readonly property string lastReloadTimeFormated: !!root.walletStore.lastReloadTimestamp ?
                                                                 LocaleUtils.formatRelativeTimestamp(
                                                                     root.walletStore.lastReloadTimestamp * 1000) : ""
                    tooltip.text: qsTr("Last refreshed %1").arg(lastReloadTimeFormated)

                    onClicked: root.walletStore.reloadAccountTokens()

                    Timer {
                        id: throttleTimer
                        interval: 1000*60 //throttle for 1 min
                        running: true // Start the timer immediately to disable manual reload initially, as automatic refresh is performed upon entering the wallet.
                    }

                    onLastReloadTimeFormatedChanged: {
                        // Start the throttle timer whenever the tokens are reloaded,
                        // which can be triggered by either automatic or manual reload.
                        throttleTimer.restart()
                    }
                }
            }

            DappsComboBox {
                id: dappsWorkflow
                Layout.alignment: Qt.AlignTop
                spacing: 8

                visible: !root.walletStore.showSavedAddresses && root.dAppsVisible
                enabled: root.dAppsEnabled
                model: root.dAppsModel
                onDappListRequested: () => root.dappListRequested()
                onDisconnectDapp: (dappUrl) => root.dappDisconnectRequested(dappUrl)
                onConnectDapp: () => root.dappConnectRequested()
            }

            StatusButton {
                id: headerButton
                objectName: "walletHeaderButton"
                Layout.preferredHeight: 38
                Layout.alignment: Qt.AlignTop

                spacing: 8
                size: StatusBaseButton.Size.Small
                borderColor: root.walletStore.showSavedAddresses? "transparent" : Theme.palette.directColor7
                normalColor: root.walletStore.showSavedAddresses? Theme.palette.primaryColor3 : Theme.palette.transparent
                hoverColor: root.walletStore.showSavedAddresses? Theme.palette.primaryColor2 : Theme.palette.baseColor2

                font.weight: root.walletStore.showSavedAddresses? Font.Medium : Font.Normal
                textPosition: StatusBaseButton.TextPosition.Left
                textColor: root.walletStore.showSavedAddresses? Theme.palette.primaryColor1 : Theme.palette.baseColor1

                icon.name: root.walletStore.showSavedAddresses? "" : "invite-users"
                icon.height: 16
                icon.width: 16
                icon.color: hovered ? Theme.palette.directColor1 : Theme.palette.baseColor1
            }

            // network filter
            NetworkFilter {
                id: networkFilter
                showTitle: false
                showManageNetworksButton: true

                Layout.alignment: Qt.AlignTop

                flatNetworks: root.networksStore.activeNetworks
                onToggleNetwork: root.networksStore.toggleNetworkEnabled(chainId)
                onManageNetworksClicked: root.manageNetworksRequested()
                showNewChainIcon: true
                showNotificationIcon: {
                    const newChains = Constants.chains.newChains
                    const seenChains = localAppSettings.seenNetworkChains
                    for (let i = 0 ; i < newChains.length ; i++) {
                        if (seenChains.indexOf(newChains[i]) === -1) {
                            return true
                        }
                    }
                    return false
                }

                popup.onOpened: {
                    if (!showNotificationIcon)
                        return
                    let seenChains = JSON.parse(localAppSettings.seenNetworkChains)
                    seenChains.push(...Constants.chains.newChains)
                    localAppSettings.seenNetworkChains = JSON.stringify(seenChains)
                }

                Binding on selection {
                    value: chainIdsAggregator.value
                }

                FunctionAggregator {
                    id: chainIdsAggregator

                    readonly property SortFilterProxyModel enabledNetworksModel: SortFilterProxyModel{
                        sourceModel: root.networksStore.activeNetworks
                        filters: ValueFilter {
                            roleName: "isEnabled"
                            value: true
                        }
                    }

                    model: enabledNetworksModel
                    initialValue: []
                    roleName: "chainId"

                    aggregateFunction: (aggr, value) => [...aggr, value]
                }
            }
        }

        RowLayout {
            spacing: 4
            visible: !root.walletStore.showSavedAddresses &&
                     !!root.networkConnectionStore &&
                     !networkConnectionStore.accountBalanceNotAvailable
            StatusTextWithLoadingState {
                font.pixelSize: 28
                font.bold: true
                customColor: Theme.palette.directColor1
                text: loading ?
                            Constants.dummyText :
                            !!root.overview?
                                LocaleUtils.currencyAmountToLocaleString(root.overview.currencyBalance) : ""
                loading: !!root.overview && root.overview.balanceLoading
                lineHeightMode: Text.FixedHeight
                lineHeight: 38
            }
        }
    }
}
