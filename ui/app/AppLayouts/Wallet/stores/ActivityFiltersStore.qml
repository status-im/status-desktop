import QtQuick 2.13

import SortFilterProxyModel 0.2

import utils 1.0

QtObject {
    id: root

    property var activityController: walletSection.activityController
    property bool filtersSet: fromTimestamp !== 0 || toTimestamp !== 0 ||
                                typeFilters.length !== 0 ||
                                statusFilters.length !== 0 ||
                                tokensFilter.length !== 0 ||
                                collectiblesFilter.length !== 0 ||
                                recentsFilters.length !== 0 ||
                                savedAddressFilters.length !== 0

    // Time filters
    property int selectedTime: Constants.TransactionTimePeriod.All
    // To-do get this from the backend once oldest Tx timestamp is available
    property double fromTimestamp
    property double toTimestamp: new Date().valueOf()
    function setSelectedTimestamp(selcTime) {
        selectedTime = selcTime
        var currDate = new Date() // current date
        switch(selectedTime) {
        case Constants.TransactionTimePeriod.All:
            fromTimestamp = 0
            toTimestamp = 0
            break
        case Constants.TransactionTimePeriod.Today:
            fromTimestamp = currDate.valueOf() // Today
            toTimestamp = fromTimestamp
            break
        case Constants.TransactionTimePeriod.Yesterday:
            fromTimestamp = new Date().setDate(currDate.getDate() - 1).valueOf() // Yesterday
            toTimestamp = fromTimestamp
            break
        case Constants.TransactionTimePeriod.ThisWeek:
            var firstDayOfCurrentWeek = currDate.getDate() - currDate.getDay()
            fromTimestamp = new Date().setDate(firstDayOfCurrentWeek).valueOf() // This week
            toTimestamp = currDate.valueOf()
            break
        case Constants.TransactionTimePeriod.LastWeek:
            fromTimestamp = new Date().setDate(currDate.getDate() - 7).valueOf() // Last week
            toTimestamp = currDate.valueOf()
            break
        case Constants.TransactionTimePeriod.ThisMonth:
            fromTimestamp = new Date().setDate(1).valueOf() // This month
            toTimestamp = currDate.valueOf()
            break
        case Constants.TransactionTimePeriod.LastMonth:
            let x = new Date()
            x.setDate(1)
            x.setMonth(x.getMonth()-1)
            fromTimestamp = x.valueOf() // Last month
            x.setDate(new Date(x.getFullYear(), x.getMonth(), 0).getDate() + 1)
            toTimestamp = x.valueOf()
            break
        default:
            return ""
        }

        activityController.setFilterTime(root.fromTimestamp/1000, root.toTimestamp/1000)
        activityController.updateFilter()
    }
    function setCustomTimeRange(fromTimestamp, toTimestamp) {
        root.fromTimestamp = fromTimestamp
        root.toTimestamp = toTimestamp

        activityController.setFilterTime(root.fromTimestamp/1000, root.toTimestamp/1000)
        activityController.updateFilter()
    }

    // Type Filters
    property var typeFilters: []
    function toggleType(type, allFiltersCount) {
        // update filters
        typeFilters = toggleFilterState(typeFilters, type, allFiltersCount)
        // Set backend values
        activityController.setFilterType(JSON.stringify(typeFilters))
        activityController.updateFilter()
    }

    // Status Filters
    property var statusFilters: []
    function toggleStatus(status, allFiltersCount) {
        // update filters
        statusFilters = toggleFilterState(statusFilters, status, allFiltersCount)
        // Set backend values
        activityController.setFilterStatus(JSON.stringify(statusFilters))
        activityController.updateFilter()
    }

    // Tokens Filters
    property var tokensList: walletSectionAssets.assets
    property var tokensFilter: []
    function toggleToken(symbol) {
        // update filters
        tokensFilter = toggleFilterState(tokensFilter, symbol, tokensList.count)
        // Set backend values
        activityController.setFilterAssets(JSON.stringify(tokensFilter))
        activityController.updateFilter()
    }

    // Collectibles Filters
    property var collectiblesList: walletSectionCollectibles.model
    property var collectiblesFilter: []
    function toggleCollectibles(id) {
        // update filters
        collectiblesFilter = toggleFilterState(collectiblesFilter, id, collectiblesList.count)
        // To-do go side filtering is pending
        //        activityController.setFilterCollectibles(JSON.stringify(collectiblesFilter))
        //        activityController.updateFilter()
    }


    // To-do get correct model unaffected by filters from go side
    property var recentsList: []
    property var recentsFilters: []
    function toggleRecents(address) {
        // update filters
        recentsFilters = toggleFilterState(recentsFilters, address, recentsList.count)
        // Set backend values
        activityController.setFilterToAddresses(JSON.stringify(recentsFilters.concat(savedAddressFilters)))
        activityController.updateFilter()
    }

    property var savedAddressesModel: walletSectionSavedAddresses.model
    property bool areTestNetworksEnabled: networksModule.areTestNetworksEnabled
    property var savedAddressList:  SortFilterProxyModel {
        sourceModel: savedAddressesModel
        filters: [
            ValueFilter {
                roleName: "isTest"
                value: areTestNetworksEnabled
            }
        ]
    }
    property var savedAddressFilters: []
    function toggleSavedAddress(address) {
        // update filters
        savedAddressFilters = toggleFilterState(savedAddressFilters, address, savedAddressList.count)
        // Set backend values
        activityController.setFilterToAddresses(JSON.stringify(recentsFilters.concat(savedAddressFilters)))
        activityController.updateFilter()
    }

    function toggleFilterState(filters, attribute, allFiltersCount) {
        let tempFilters = filters
        // if all were selected then only select one of them
        if(tempFilters.length === 0) {
            tempFilters = [attribute]
        }
        else {
            // if last one is being deselected, select all
            if(tempFilters.length === 1 && tempFilters[0] === attribute) {
                tempFilters = []
            }
            else {
                let index = tempFilters.indexOf(attribute)
                if(index === -1) {
                    if(allFiltersCount === tempFilters.length + 1)
                        tempFilters = []
                    else
                        tempFilters.push(attribute)
                }
                else {
                    tempFilters.splice(index, 1)
                }
            }
        }
        return tempFilters
    }
}
