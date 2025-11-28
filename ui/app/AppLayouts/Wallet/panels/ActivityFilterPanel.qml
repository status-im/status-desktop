import QtQuick

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils as StatusQUtils
import StatusQ.Controls

import utils

import shared.panels

import "../controls"
import "../popups"
import "../stores" as WalletStores

Column {
    id: root

    property var activityFilterStore
    property WalletStores.RootStore store
    property bool isLoading: false
    property bool hideNoResults: false

    spacing: 12

    function resetView() {
        activityFilterMenu.resetView()
    }

    Flow {
        width: parent.width

        spacing: 8

        StatusComboBox {
            height: 34
            size: StatusComboBox.Size.Small
            type: StatusComboBox.Type.Secondary
            control.displayText: qsTr("Filter")
            control.popup.onOpened: {
                activityFilterStore.updateStartTimestamp()
                activityFilterMenu.popup(x, y + height + 4)
            }
        }

        ActivityFilterTagItem {
            tagPrimaryLabel.text: LocaleUtils.formatDate(activityFilterStore.fromTimestamp)
            tagSecondaryLabel.text: {
                switch(activityFilterMenu.selectedTime) {
                case Constants.TransactionTimePeriod.Today:
                case Constants.TransactionTimePeriod.Yesterday:
                    return ""
                default:
                    return LocaleUtils.formatDate(activityFilterStore.toTimestamp)
                }
            }
            middleLabel.text: {
                switch(activityFilterMenu.selectedTime) {
                case Constants.TransactionTimePeriod.Today:
                case Constants.TransactionTimePeriod.Yesterday:
                    return ""
                default:
                    return qsTr("to")
                }
            }
            asset.name: "history"
            visible: activityFilterMenu.selectedTime !== Constants.TransactionTimePeriod.All
            onClosed: activityFilterStore.setSelectedTimestamp(Constants.TransactionTimePeriod.All)
        }

        Repeater {
            model: activityFilterMenu.allTypesChecked ? 0: activityFilterStore.typeFilters
            delegate: ActivityFilterTagItem {
                property int type: activityFilterStore.typeFilters[index]
                tagPrimaryLabel.text: switch(activityFilterStore.typeFilters[index]) {
                                      case Constants.TransactionType.Send:
                                          return qsTr("Send")
                                      case Constants.TransactionType.Receive:
                                          return qsTr("Receive")
                                      case Constants.TransactionType.Swap:
                                          return qsTr("Swap")
                                      case Constants.TransactionType.Bridge:
                                          return qsTr("Bridge")
                                      case Constants.TransactionType.ContractDeployment:
                                          return qsTr("Contract Deployment")
                                      case Constants.TransactionType.Mint:
                                          return qsTr("Mint")
                                      case Constants.TransactionType.ContractInteraction:
                                          return qsTr("Contract Interaction")
                                      default:
                                          console.warn("Unhandled type :: ",activityFilterStore.typeFilters[index])
                                          return ""
                                      }
                asset.name: switch(activityFilterStore.typeFilters[index]) {
                                case Constants.TransactionType.Send:
                                    return "send"
                                case Constants.TransactionType.Receive:
                                    return "receive"
                                case Constants.TransactionType.Swap:
                                    return "swap"
                                case Constants.TransactionType.Bridge:
                                    return "bridge"
                                case Constants.TransactionType.ContractDeployment:
                                    return "contract_deploy"
                                case Constants.TransactionType.Mint:
                                    return "token"
                                case Constants.TransactionType.ContractInteraction:
                                    return "contract_interaction"
                                default:
                                    console.warn("Unhandled type :: ",activityFilterStore.typeFilters[index])
                                    return ""
                                }
                onClosed: activityFilterStore.toggleType(type)
            }
        }

        Repeater {
            model: activityFilterMenu.allStatusChecked ? 0 : activityFilterStore.statusFilters
            delegate: ActivityFilterTagItem {
                property int status: activityFilterStore.statusFilters[index]
                tagPrimaryLabel.text: switch(activityFilterStore.statusFilters[index]) {
                                      case Constants.TransactionStatus.Failed:
                                          return qsTr("Failed")
                                      case Constants.TransactionStatus.Pending:
                                          return qsTr("Pending")
                                      case Constants.TransactionStatus.Complete:
                                          return qsTr("Complete")
                                      case Constants.TransactionStatus.Finalised:
                                          return qsTr("Finalised")
                                      default:
                                          console.warn("Unhandled status :: ",activityFilterStore.statusFilters[index])
                                          return ""
                                      }
                asset.name: switch(activityFilterStore.statusFilters[index]) {
                                case Constants.TransactionStatus.Failed:
                                    return Assets.svg("transaction/failed")
                                case Constants.TransactionStatus.Pending:
                                    return Assets.svg("transaction/pending")
                                case Constants.TransactionStatus.Complete:
                                    return Assets.svg("transaction/confirmed")
                                case Constants.TransactionStatus.Finished:
                                    return Assets.svg("transaction/finished")
                                default:
                                    console.warn("Unhandled status :: ",activityFilterStore.statusFilters[index])
                                    return ""
                                }
                asset.color: "transparent"
                onClosed: activityFilterStore.toggleStatus(status, activityFilterMenu.allStatusChecked)
            }
        }

        Repeater {
            model: activityFilterStore.tokensFilter
            delegate: ActivityFilterTagItem {
                tagPrimaryLabel.text: modelData
                asset.name: Constants.tokenIcon(modelData)
                asset.color: "transparent"
                onClosed: activityFilterStore.toggleToken(modelData)
            }
        }

        Repeater {
            model: activityFilterStore.collectiblesFilter
            delegate: ActivityFilterTagItem {
                id: collectibleTag
                property string uid: modelData
                readonly property string name: activityFilterStore.collectiblesList.getName(uid)
                readonly property bool isValid: name.length > 0
                tagPrimaryLabel.text: {
                    if (!!name)
                        return name
                    // Fallback, get tokenId from uid
                    const data = uid.split("+")
                    if (data.length === 3)
                        return "#" + data[2]
                    return ""
                }
                asset.name: activityFilterStore.collectiblesList.getImageUrl(uid)
                asset.color: "transparent"
                onClosed: activityFilterStore.toggleCollectibles(uid)

                Connections {
                    // Collectibles model is fetched asynchronously, so data might not be available
                    target: activityFilterStore
                    enabled: !collectibleTag.isValid
                    function onLoadingCollectiblesChanged() {
                        if (activityFilterStore.loadingCollectibles || !activityFilterStore.collectiblesList.hasMore)
                            return
                        collectibleTag.uid = ""
                        collectibleTag.uid = modelData
                        if (!collectibleTag.isValid)
                            activityFilterStore.collectiblesList.loadMore()
                    }
                }
            }
        }

        Repeater {
            model: activityFilterStore.recentsFilters

            // Use lazy loading as a workaround to refresh the list when the model is updated
            // to force an address lookup to all delegates
            delegate: Loader {
                active: parent.visible
                sourceComponent: ActivityFilterTagItem {
                    tagPrimaryLabel.text: root.store.getNameForAddress(modelData) || StatusQUtils.Utils.elideText(modelData,6,4)
                    onClosed: activityFilterStore.toggleRecents(modelData)
                }
            }
        }

        Repeater {
            model: activityFilterStore.savedAddressFilters
            delegate: ActivityFilterTagItem {
                tagPrimaryLabel.text: {
                    let savedAddress = root.store.getSavedAddress(modelData)
                    return savedAddress.name
                }
                onClosed: activityFilterStore.toggleSavedAddress(modelData)
            }
        }
    }

    Separator {
        visible: noResultsAfterFilter.noResults
    }

    StatusBaseText {
        id: noResultsAfterFilter
        readonly property bool noResults: !root.isLoading && activityFilterStore.transactionsList.count === 0 && activityFilterStore.filtersSet
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 16
        visible: !root.hideNoResults && noResults
        text: qsTr("No activity items for the current filter")
        color: Theme.palette.baseColor1
    }

    StatusButton {
        anchors.horizontalCenter: parent.horizontalCenter
        visible: noResultsAfterFilter.visible
        text: qsTr("Clear all filters")
        size: StatusBaseButton.Size.Small
        onClicked: activityFilterStore.resetAllFilters()
    }

    ActivityFilterMenu {
        id: activityFilterMenu

        selectedTime: activityFilterStore.selectedTime
        onSetSelectedTime: {
            if(selectedTime === Constants.TransactionTimePeriod.Custom) {
                dialog.open()
            }
            else {
                activityFilterStore.setSelectedTimestamp(selectedTime)
            }
        }

        typeFilters: activityFilterStore.typeFilters
        onUpdateTypeFilter: activityFilterStore.toggleType(type, allFiltersCount)

        statusFilters: activityFilterStore.statusFilters
        onUpdateStatusFilter: activityFilterStore.toggleStatus(status, allFiltersCount)

        tokensList: activityFilterStore.tokensList
        tokensFilter: activityFilterStore.tokensFilter
        collectiblesList: activityFilterStore.collectiblesList
        collectiblesFilter: activityFilterStore.collectiblesFilter
        onUpdateTokensFilter: activityFilterStore.toggleToken(tokenSymbol)
        onUpdateCollectiblesFilter: activityFilterStore.toggleCollectibles(uid)

        store: root.store
        recentsList: activityFilterStore.recentsList
        loadingRecipients: activityFilterStore.loadingRecipients
        loadingCollectibles: activityFilterStore.loadingCollectibles
        recentsFilters: activityFilterStore.recentsFilters
        savedAddressList: activityFilterStore.savedAddressList
        savedAddressFilters: activityFilterStore.savedAddressFilters
        onUpdateSavedAddressFilter: activityFilterStore.toggleSavedAddress(address)
        onUpdateRecentsFilter: activityFilterStore.toggleRecents(address)
        onUpdateRecipientsModel: activityFilterStore.updateRecipientsModel()
    }

    StatusDateRangePicker {
        id: dialog
        anchors.centerIn: parent
        fromTimestamp: activityFilterStore.currentActivityStartTimestamp
        toTimestamp: new Date().valueOf()
        onNewRangeSet: {
            activityFilterStore.setCustomTimeRange(fromTimestamp, toTimestamp)
            activityFilterStore.setSelectedTimestamp(Constants.TransactionTimePeriod.Custom)
        }
    }
}
