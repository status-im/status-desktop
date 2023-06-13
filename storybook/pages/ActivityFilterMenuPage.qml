import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.popups 1.0
import AppLayouts.Wallet.panels 1.0
import AppLayouts.stores 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import SortFilterProxyModel 0.2

import Storybook 1.0

import Models 1.0

import utils 1.0

import shared.controls 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    QtObject {
        id: d
        property int selectedTime: Constants.TransactionTimePeriod.All
        property double fromTimestamp: new Date().setDate(new Date().getDate() - 7)
        property double toTimestamp: Date.now()
        function changeSelectedTime(newTime) {
            selectedTime = newTime
        }
        function setCustomTimeRange(fromTimestamp , toTimestamp) {
            d.fromTimestamp = fromTimestamp
            d.toTimestamp = toTimestamp
        }
        property var typeFilters: [
            Constants.TransactionType.Send,
            Constants.TransactionType.Receive,
            Constants.TransactionType.Buy,
            Constants.TransactionType.Swap,
            Constants.TransactionType.Bridge]

        function toggleType(type) {
            let tempFilters = typeFilters
            let allCheckedIs = false
            if(tempFilters.length === 5)
                allCheckedIs = true

            // if all were selected then only select one of them
            if(allCheckedIs) {
                tempFilters = [type]
            }
            else {
                // if last one is being deselected, select all
                if(tempFilters.length === 1 && tempFilters[0] === type) {
                    tempFilters = [
                                Constants.TransactionType.Send,
                                Constants.TransactionType.Receive,
                                Constants.TransactionType.Buy,
                                Constants.TransactionType.Swap,
                                Constants.TransactionType.Bridge]
                }
                else {
                    let index = tempFilters.indexOf(type)
                    if(index === -1) {
                        tempFilters.push(type)
                    }
                    else {
                        tempFilters.splice(index, 1)
                    }
                }
            }
            typeFilters = tempFilters
        }

        property var statusFilters: [
            Constants.TransactionStatus.Failed,
            Constants.TransactionStatus.Pending,
            Constants.TransactionStatus.Complete,
            Constants.TransactionStatus.Finished]

        function toggleStatus(status) {
            let tempFilters = statusFilters
            let allCheckedIs = false
            if(tempFilters.length === 4)
                allCheckedIs = true

            // if all were selected then only select one of them
            if(allCheckedIs) {
                tempFilters = [status]
            }
            else {
                // if last one is being deselected, select all
                if(tempFilters.length === 1 && tempFilters[0] === status) {
                    tempFilters = [
                                Constants.TransactionStatus.Failed,
                                Constants.TransactionStatus.Pending,
                                Constants.TransactionStatus.Complete,
                                Constants.TransactionStatus.Finished]
                }
                else {
                    let index = tempFilters.indexOf(status)
                    if(index === -1) {
                        tempFilters.push(status)
                    }
                    else {
                        tempFilters.splice(index, 1)
                    }
                }
            }
            statusFilters = tempFilters
        }

        property var simulatedAssetsModel: WalletAssetsModel {}
        function toggleToken(tokenSymbol) {
            let tempodel = simulatedAssetsModel
            let allChecked = true
            let allChecked1 = true
            let checkedTokens = []
            simulatedAssetsModel = []
            for (let k =0; k<tempodel.count; k++) {
                if(!tempodel.get(k).checked)
                    allChecked = false
                else {
                    checkedTokens.push(tempodel.get(k))
                }
            }

            if(allChecked) {
                for (let i = 0; i<tempodel.count; i++) {
                    if(tempodel.get(i).symbol === tokenSymbol) {
                        tempodel.get(i).checked = true
                    }
                    else
                        tempodel.get(i).checked = false
                }

            }
            else if(checkedTokens.length === 1 && checkedTokens[0].symbol === tokenSymbol) {
                for (let j = 0; j<tempodel.count; j++) {
                    tempodel.get(j).checked = true
                    tempodel.get(j).allChecked = true
                }
            }
            else {
                for (let l =0; l<tempodel.count; l++) {
                    if(tempodel.get(l).symbol === tokenSymbol)
                        tempodel.get(l).checked = !tempodel.get(l).checked
                }
            }
            for (let l =0; l<tempodel.count; l++) {
                if(!tempodel.get(l).checked)
                    allChecked1 = false
            }
            for (let j =0; j<tempodel.count; j++) {
                tempodel.get(j).allChecked = allChecked1
            }
            simulatedAssetsModel = tempodel
        }

        property var simulatedCollectiblesModel: CollectiblesModel {}
        function toggleCollectibles(name) {
            let tempodel = simulatedCollectiblesModel
            let allChecked = true
            let allChecked1 = true
            let checkedTokens = []
            simulatedCollectiblesModel = []
            for (let k =0; k<tempodel.count; k++) {
                if(!tempodel.get(k).checked)
                    allChecked = false
                else {
                    checkedTokens.push(tempodel.get(k))
                }
            }

            if(allChecked) {
                for (let i = 0; i<tempodel.count; i++) {
                    if(tempodel.get(i).name === name) {
                        tempodel.get(i).checked = true
                    }
                    else
                        tempodel.get(i).checked = false
                }

            }
            else if(checkedTokens.length === 1 && checkedTokens[0].name === name) {
                for (let j = 0; j<tempodel.count; j++) {
                    tempodel.get(j).checked = true
                    tempodel.get(j).allChecked = true
                }
            }
            else {
                for (let l =0; l<tempodel.count; l++) {
                    if(tempodel.get(l).name === name)
                        tempodel.get(l).checked = !tempodel.get(l).checked
                }
            }
            for (let l =0; l<tempodel.count; l++) {
                if(!tempodel.get(l).checked)
                    allChecked1 = false
            }
            for (let j =0; j<tempodel.count; j++) {
                tempodel.get(j).allChecked = allChecked1
            }
            simulatedCollectiblesModel = tempodel
        }

        property var recipeintModel: RecipientModel {}
        property var simulatedSavedList: recipeintModel.savedAddresses
        property var simulatedRecentsList: recipeintModel.recents

        function toggleSavedAddress(address) {
            let tempodel = simulatedSavedList
            let allChecked = true
            let allChecked1 = true
            let checkedTokens = []
            simulatedSavedList = []
            for (let k =0; k<tempodel.count; k++) {
                if(!tempodel.get(k).checked)
                    allChecked = false
                else {
                    checkedTokens.push(tempodel.get(k))
                }
            }

            if(allChecked) {
                for (let i = 0; i<tempodel.count; i++) {
                    if(tempodel.get(i).address === address) {
                        tempodel.get(i).checked = true
                    }
                    else
                        tempodel.get(i).checked = false
                }

            }
            else if(checkedTokens.length === 1 && checkedTokens[0].address === address) {
                for (let j = 0; j<tempodel.count; j++) {
                    tempodel.get(j).checked = true
                    tempodel.get(j).allChecked = true
                }
            }
            else {
                for (let l =0; l<tempodel.count; l++) {
                    if(tempodel.get(l).address === address)
                        tempodel.get(l).checked = !tempodel.get(l).checked
                }
            }
            for (let l =0; l<tempodel.count; l++) {
                if(!tempodel.get(l).checked)
                    allChecked1 = false
            }
            for (let j =0; j<tempodel.count; j++) {
                tempodel.get(j).allChecked = allChecked1
            }
            simulatedSavedList = tempodel
        }

        function toggleRecents(address) {
            let tempodel = simulatedRecentsList
            let allChecked = true
            let allChecked1 = true
            let checkedTokens = []
            simulatedRecentsList = []
            for (let k =0; k<tempodel.count; k++) {
                if(!tempodel.get(k).checked)
                    allChecked = false
                else {
                    checkedTokens.push(tempodel.get(k))
                }
            }

            if(allChecked) {
                for (let i = 0; i<tempodel.count; i++) {
                    let addresstoFind = tempodel.get(i).to.toLowerCase() === d.store.overview.mixedcaseAddress.toLowerCase() ? tempodel.get(i).from : tempodel.get(i).to
                    if(addresstoFind === address) {
                        tempodel.get(i).checked = true
                    }
                    else
                        tempodel.get(i).checked = false
                }

            }
            else if(checkedTokens.length === 1 && (checkedTokens[0].to.toLowerCase() === d.store.overview.mixedcaseAddress.toLowerCase() ? checkedTokens[0].from : checkedTokens[0].to) === address) {
                for (let j = 0; j<tempodel.count; j++) {
                    tempodel.get(j).checked = true
                    tempodel.get(j).allChecked = true
                }
            }
            else {
                for (let l =0; l<tempodel.count; l++) {
                    let addresstoFind = tempodel.get(l).to.toLowerCase() === d.store.overview.mixedcaseAddress.toLowerCase() ? tempodel.get(l).from : tempodel.get(l).to
                    if(addresstoFind === address )
                        tempodel.get(l).checked = !tempodel.get(l).checked
                }
            }
            for (let m =0; m<tempodel.count; m++) {
                if(!tempodel.get(m).checked)
                    allChecked1 = false
            }
            for (let n =0; n<tempodel.count; n++) {
                tempodel.get(n).allChecked = allChecked1
            }
            simulatedRecentsList = tempodel
        }

        property var store: QtObject {
            property var overview: ({
                                        name: "helloworld",
                                        mixedcaseAddress: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7421",
                                        ens: "",
                                        color: color,
                                        emoji: "⚽",
                                        balanceLoading: false,
                                        hasBalanceCache: true,
                                        currencyBalance: ({amount: 1.25,
                                                              symbol: "USD",
                                                              displayDecimals: 4,
                                                              stripTrailingZeroes: false}),
                                        isAllAccounts: false,
                                        hideWatchAccounts: false

                                    })

            function getNameForAddress(address) {
                return ""
            }
        }
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        ActivityFilterPanel {
            id: filterComponent
            width: 800
            anchors.centerIn: parent
            store: d.store
            fromTimestamp: d.fromTimestamp
            toTimestamp: d.toTimestamp
            selectedTime: d.selectedTime
            typeFilters: d.typeFilters
            statusFilters: d.statusFilters
            assetsList: d.simulatedAssetsModel
            collectiblesList: d.simulatedCollectiblesModel
            savedAddressList: d.simulatedSavedList
            recentsList: d.simulatedRecentsList
            onChangeSelectedTime: d.changeSelectedTime(selectedTime)
            onSetCustomTimeRange: d.setCustomTimeRange(from, to)
            onToggleType: d.toggleType(type)
            onToggleStatus: d.toggleStatus(status)
            onToggleToken: d.toggleToken(tokenSymbol)
            onToggleCollectibles: d.toggleCollectibles(name)
            onToggleSavedAddress: d.toggleSavedAddress(address)
            onToggleRecents: d.toggleRecents(address)
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        ButtonGroup {
            buttons: periodRow.children
        }

        Column {
            spacing: 20

            Row {
                id: periodRow
                spacing: 20

                RadioButton {
                    checked: true
                    text: "All"
                    onCheckedChanged: if(checked) { d.selectedTime =  Constants.TransactionTimePeriod.All}
                }
                RadioButton {
                    text: "Today"
                    onCheckedChanged: if(checked) { d.selectedTime =  Constants.TransactionTimePeriod.Today}
                }
                RadioButton {
                    text: "Yesterday"
                    onCheckedChanged: if(checked) { d.selectedTime =  Constants.TransactionTimePeriod.Yesterday}
                }
                RadioButton {
                    text: "ThisWeek"
                    onCheckedChanged: if(checked) { d.selectedTime =  Constants.TransactionTimePeriod.ThisWeek}
                }
                RadioButton {
                    text: "LastWeek"
                    onCheckedChanged: if(checked) { d.selectedTime =  Constants.TransactionTimePeriod.LastWeek}
                }
                RadioButton {
                    text: "ThisMonth"
                    onCheckedChanged: if(checked) { d.selectedTime =  Constants.TransactionTimePeriod.ThisMonth}
                }
                RadioButton {
                    text: "LastMonth"
                    onCheckedChanged: if(checked) { d.selectedTime =  Constants.TransactionTimePeriod.LastMonth}
                }
                RadioButton {
                    text: "Custom"
                    onCheckedChanged: if(checked) { d.selectedTime =  Constants.TransactionTimePeriod.Custom}
                }
            }

            Row {
                spacing: 20
                CheckBox {
                    text: "Send"
                    checked: d.typeFilters.includes(Constants.TransactionType.Send)
                    onClicked: d.toggleType(Constants.TransactionType.Send)
                }
                CheckBox {
                    text: "Receive"
                    checked: d.typeFilters.includes(Constants.TransactionType.Receive)
                    onClicked: d.toggleType(Constants.TransactionType.Receive)
                }
                CheckBox {
                    text: "Buy"
                    checked: d.typeFilters.includes(Constants.TransactionType.Buy)
                    onClicked: d.toggleType(Constants.TransactionType.Buy)
                }
                CheckBox {
                    text: "Swap"
                    checked: d.typeFilters.includes(Constants.TransactionType.Swap)
                    onClicked: d.toggleType(Constants.TransactionType.Swap)
                }
                CheckBox {
                    text: "Bridge"
                    checked: d.typeFilters.includes(Constants.TransactionType.Bridge)
                    onClicked: d.toggleType(Constants.TransactionType.Bridge)
                }
            }


            Row {
                spacing: 20
                CheckBox {
                    text: "Failed"
                    checked: d.statusFilters.includes(Constants.TransactionStatus.Failed)
                    onClicked: d.toggleStatus(Constants.TransactionStatus.Failed)
                }
                CheckBox {
                    text: "Pending"
                    checked: d.statusFilters.includes(Constants.TransactionStatus.Pending)
                    onClicked: d.toggleStatus(Constants.TransactionStatus.Pending)
                }
                CheckBox {
                    text: "Complete"
                    checked: d.statusFilters.includes(Constants.TransactionStatus.Complete)
                    onClicked: d.toggleStatus(Constants.TransactionStatus.Complete)
                }
                CheckBox {
                    text: "Finished"
                    checked: d.statusFilters.includes(Constants.TransactionStatus.Finished)
                    onClicked: d.toggleStatus(Constants.TransactionStatus.Finished)
                }
            }
        }
    }
}
