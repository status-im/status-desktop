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

    property var store
    property int selectedTime
    property double fromTimestamp
    property double toTimestamp
    property var typeFilters
    property var statusFilters
    property var assetsList
    property var collectiblesList
    property var savedAddressList
    property var recentsList

    signal changeSelectedTime(int selectedTime)
    signal setCustomTimeRange(string from, string to)
    signal toggleType(int type)
    signal toggleStatus(int status)
    signal toggleToken(string tokenSymbol)
    signal toggleCollectibles(string name)
    signal toggleSavedAddress(string address)
    signal toggleRecents(string address)

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
        tagPrimaryLabel.text: {
            var currDate = new Date; // current date
            switch(root.selectedTime) {
            case Constants.TransactionTimePeriod.Today:
                return LocaleUtils.formatDate(currDate) // Today
            case Constants.TransactionTimePeriod.Yesterday:
                return LocaleUtils.formatDate(new Date().setDate(currDate.getDate() - 1)) // Yesterday
            case Constants.TransactionTimePeriod.ThisWeek:
                var firstDayOfCurrentWeek = currDate.getDate() - currDate.getDay()
                return LocaleUtils.formatDate(currDate.setDate(firstDayOfCurrentWeek)) // This week
            case Constants.TransactionTimePeriod.LastWeek:
                return LocaleUtils.formatDate(new Date().setDate(currDate.getDate() - 7)) // Last week
            case Constants.TransactionTimePeriod.ThisMonth:
                return LocaleUtils.formatDate(currDate.setDate(1)) // This month
            case Constants.TransactionTimePeriod.LastMonth:
                currDate.setDate(1);
                currDate.setMonth(currDate.getMonth()-1);
                return LocaleUtils.formatDate(currDate) // Last month
            case Constants.TransactionTimePeriod.Custom:
                return LocaleUtils.formatDate(new Date(root.fromTimestamp)) // Custom
            default:
                return ""
            }
        }
        tagSecondaryLabel.text: {
            switch(root.selectedTime) {
            case Constants.TransactionTimePeriod.Today:
            case Constants.TransactionTimePeriod.Yesterday:
                return ""
            case Constants.TransactionTimePeriod.ThisWeek:
            case Constants.TransactionTimePeriod.LastWeek:
            case Constants.TransactionTimePeriod.ThisMonth:
                return LocaleUtils.formatDate(new Date)
            case Constants.TransactionTimePeriod.LastMonth:
                let x = new Date()
                x.setDate(1);
                x.setMonth(x.getMonth()-1);
                x.setDate(new Date(x.getFullYear(), x.getMonth(), 0).getDate() + 1)
                return LocaleUtils.formatDate(x)
            case Constants.TransactionTimePeriod.Custom:
                return LocaleUtils.formatDate(new Date(root.toTimestamp)) // Custom
            default:
                return ""
            }
        }
        middleLabel.text:{
            switch(root.selectedTime) {
            case Constants.TransactionTimePeriod.Today:
            case Constants.TransactionTimePeriod.Yesterday:
                return ""
            default:
                return qsTr("to")
            }
        }

        iconAsset.icon: "history"
        visible: root.selectedTime !== Constants.TransactionTimePeriod.All
        onClosed: root.changeSelectedTime(Constants.TransactionTimePeriod.All)
    }

    Repeater {
        model: activityFilterMenu.allTypesChecked ? 0: root.typeFilters
        delegate: ActivityFilterTagItem {
            property int type: root.typeFilters[index]
            tagPrimaryLabel.text: switch(root.typeFilters[index]) {
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
                                      console.warn("Unhandled type :: ",root.typeFilters[index])
                                      return ""
                                  }
            iconAsset.icon: switch(root.typeFilters[index]) {
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
                                console.warn("Unhandled type :: ",root.typeFilters[index])
                                return ""
                            }
            onClosed: root.toggleType(type)
        }
    }

    Repeater {
        model: activityFilterMenu.allStatusChecked ? 0 : root.statusFilters
        delegate: ActivityFilterTagItem {
            property int type: root.statusFilters[index]
            tagPrimaryLabel.text: switch(root.statusFilters[index]) {
                                  case Constants.TransactionStatus.Failed:
                                      return qsTr("Failed")
                                  case Constants.TransactionStatus.Pending:
                                      return qsTr("Pending")
                                  case Constants.TransactionStatus.Complete:
                                      return qsTr("Complete")
                                  case Constants.TransactionStatus.Finished:
                                      return qsTr("Finalised")
                                  default:
                                      console.warn("Unhandled status :: ",root.statusFilters[index])
                                      return ""
                                  }
            iconAsset.icon: switch(root.statusFilters[index]) {
                            case Constants.TransactionStatus.Failed:
                                return Style.svg("transaction/failed")
                            case Constants.TransactionStatus.Pending:
                                return Style.svg("transaction/pending")
                            case Constants.TransactionStatus.Complete:
                                return Style.svg("transaction/verified")
                            case Constants.TransactionStatus.Finished:
                                return Style.svg("transaction/finished")
                            default:
                                console.warn("Unhandled status :: ",root.statusFilters[index])
                                return ""
                            }
            iconAsset.color: "transparent"
            onClosed: root.toggleStatus(type)
        }
    }

    Repeater {
        model: root.assetsList
        delegate: ActivityFilterTagItem {
            tagPrimaryLabel.text: symbol
            iconAsset.icon: Constants.tokenIcon(symbol)
            iconAsset.color: "transparent"
            visible: !allChecked && checked
            onClosed: root.toggleToken(symbol)
        }
    }

    Repeater {
        model: root.collectiblesList
        delegate: ActivityFilterTagItem {
            tagPrimaryLabel.text: name
            iconAsset.icon: model.iconSource
            iconAsset.color: "transparent"
            visible: !allChecked && checked
            onClosed: root.toggleCollectibles(name)
        }
    }

    Repeater {
        model: root.recentsList
        delegate: ActivityFilterTagItem {
            property int transactionType: to.toLowerCase() === root.store.overview.mixedcaseAddress.toLowerCase() ? Constants.TransactionType.Receive : Constants.TransactionType.Send
            tagPrimaryLabel.text: transactionType === Constants.TransactionType.Receive ?
                                      root.store.getNameForAddress(from) || StatusQUtils.Utils.elideText(from,6,4) :
                                      root.store.getNameForAddress(to) || StatusQUtils.Utils.elideText(to,6,4)
            visible: !allChecked && checked
            onClosed: root.toggleRecents(transactionType === Constants.TransactionType.Receive ? from : to)
        }
    }

    Repeater {
        model: root.savedAddressList
        delegate: ActivityFilterTagItem {
            tagPrimaryLabel.text: ens.length > 0 ? ens : chainShortNames + StatusQUtils.Utils.elideText(address,6,4)
            visible: !allChecked && checked
            onClosed: root.toggleSavedAddress(address)
        }
    }

    ActivityFilterMenu {
        id: activityFilterMenu

        selectedTime: root.selectedTime
        onSetSelectedTime: {
            if(selectedTime === Constants.TransactionTimePeriod.Custom) {
                dialog.open()
            }
            else
                root.changeSelectedTime(selectedTime)
        }

        typeFilters: root.typeFilters
        onUpdateTypeFilter: root.toggleType(type)

        statusFilters: root.statusFilters
        onUpdateStatusFilter: root.toggleStatus(status)

        tokensList: root.assetsList
        collectiblesList: root.collectiblesList
        onUpdateTokensFilter: root.toggleToken(tokenSymbol)
        onUpdateCollectiblesFilter: root.toggleCollectibles(name)

        store: root.store
        recentsList: root.recentsList
        savedAddressList: root.savedAddressList
        onUpdateSavedAddressFilter: root.toggleSavedAddress(address)
        onUpdateRecentsFilter: root.toggleRecents(address)
    }

    StatusDateRangePicker {
        id: dialog
        anchors.centerIn: parent
        // To-do sync with backend
        fromTimestamp: root.fromTimestamp// 7 days ago
        toTimestamp: root.toTimestamp
        onNewRangeSet: {
            root.setCustomTimeRange(fromTimestamp, toTimestamp)
            root.changeSelectedTime(Constants.TransactionTimePeriod.Custom)
        }
    }
}
