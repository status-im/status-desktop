import QtQuick 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Controls 0.1

import utils 1.0

import "../controls"
import "../popups"

Flow {
    id: root

    property var activityFilterStore
    property var store

    spacing: 8

    StatusRoundButton {
        id: filterButton
        width: 32
        height: 32
        icon.name: "filter"
        border.width: 1
        border.color:  Theme.palette.directColor8
        type: StatusRoundButton.Type.Tertiary
        onClicked: activityFilterMenu.popup(x, y + height + 4)
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
        iconAsset.icon: "history"
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
                                  case Constants.TransactionType.Buy:
                                      return qsTr("Buy")
                                  case Constants.TransactionType.Swap:
                                      return qsTr("Swap")
                                  case Constants.TransactionType.Bridge:
                                      return qsTr("Bridge")
                                  default:
                                      console.warn("Unhandled type :: ",activityFilterStore.typeFilters[index])
                                      return ""
                                  }
            iconAsset.icon: switch(activityFilterStore.typeFilters[index]) {
                            case Constants.TransactionType.Send:
                                return "send"
                            case Constants.TransactionType.Receive:
                                return "receive"
                            case Constants.TransactionType.Buy:
                                return "token"
                            case Constants.TransactionType.Swap:
                                return "swap"
                            case Constants.TransactionType.Bridge:
                                return "bridge"
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
                                  case Constants.TransactionStatus.Finished:
                                      return qsTr("Finalised")
                                  default:
                                      console.warn("Unhandled status :: ",activityFilterStore.statusFilters[index])
                                      return ""
                                  }
            iconAsset.icon: switch(activityFilterStore.statusFilters[index]) {
                            case Constants.TransactionStatus.Failed:
                                return Style.svg("transaction/failed")
                            case Constants.TransactionStatus.Pending:
                                return Style.svg("transaction/pending")
                            case Constants.TransactionStatus.Complete:
                                return Style.svg("transaction/verified")
                            case Constants.TransactionStatus.Finished:
                                return Style.svg("transaction/finished")
                            default:
                                console.warn("Unhandled status :: ",activityFilterStore.statusFilters[index])
                                return ""
                            }
            iconAsset.color: "transparent"
            onClosed: activityFilterStore.toggleStatus(status, activityFilterMenu.allStatusChecked)
        }
    }

    Repeater {
        model: activityFilterStore.tokensList
        delegate: ActivityFilterTagItem {
            tagPrimaryLabel.text: symbol
            iconAsset.icon: Constants.tokenIcon(symbol)
            iconAsset.color: "transparent"
            visible: !activityFilterMenu.allTokensChecked && activityFilterStore.tokensFilter.includes(symbol)
            onClosed: activityFilterStore.toggleToken(symbol)
        }
    }

    Repeater {
        model: activityFilterStore.collectiblesList
        delegate: ActivityFilterTagItem {
            tagPrimaryLabel.text: model.name
            iconAsset.icon: model.imageUrl
            iconAsset.color: "transparent"
            visible: !activityFilterMenu.allCollectiblesChecked && activityFilterStore.collectiblesFilter.includes(model.id)
            onClosed: activityFilterStore.toggleCollectibles(model.id)
        }
    }

    Repeater {
        model: activityFilterStore.recentsList
        delegate: ActivityFilterTagItem {
            property int transactionType: to.toLowerCase() === root.store.overview.mixedcaseAddress.toLowerCase() ? Constants.TransactionType.Receive : Constants.TransactionType.Send
            tagPrimaryLabel.text: transactionType === Constants.TransactionType.Receive ?
                                      root.store.getNameForAddress(from) || StatusQUtils.Utils.elideText(from,6,4) :
                                      root.store.getNameForAddress(to) || StatusQUtils.Utils.elideText(to,6,4)
            visible: !activityFilterMenu.allRecentsChecked && activityFilterMenu.recentsFilters.includes(transactionType === Constants.TransactionType.Receive ? from : to)
            onClosed: activityFilterStore.toggleRecents(transactionType === Constants.TransactionType.Receive ? from : to)
        }
    }

    Repeater {
        model: activityFilterStore.savedAddressList
        delegate: ActivityFilterTagItem {
            tagPrimaryLabel.text: ens.length > 0 ? ens : chainShortNames + StatusQUtils.Utils.elideText(address,6,4)
            visible: !activityFilterMenu.allSavedAddressesChecked && activityFilterMenu.savedAddressFilters.includes(address)
            onClosed: activityFilterStore.toggleSavedAddress(address)
        }
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
        onUpdateCollectiblesFilter: activityFilterStore.toggleCollectibles(id)

        store: root.store
        recentsList: activityFilterStore.recentsList
        recentsFilters: activityFilterStore.recentsFilters
        savedAddressList: activityFilterStore.savedAddressList
        savedAddressFilters: activityFilterStore.savedAddressFilters
        onUpdateSavedAddressFilter: activityFilterStore.toggleSavedAddress(address)
        onUpdateRecentsFilter: activityFilterStore.toggleRecents(address)
    }

    StatusDateRangePicker {
        id: dialog
        anchors.centerIn: parent
        fromTimestamp: activityFilterStore.fromTimestamp
        toTimestamp: activityFilterStore.toTimestamp
        onNewRangeSet: {
            activityFilterStore.setCustomTimeRange(fromTimestamp, toTimestamp)
            activityFilterStore.setSelectedTimestamp(Constants.TransactionTimePeriod.Custom)
        }
    }
}
