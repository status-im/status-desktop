import QtQuick 2.13

import SortFilterProxyModel 0.2
import StatusQ.Core 0.1

import utils 1.0

QtObject {
    id: root

    property var transactionsList: walletSection.activityController.model

    property var activityController: walletSection.activityController
    property bool filtersSet: selectedTime !== Constants.TransactionTimePeriod.All ||
                                typeFilters.length !== 0 ||
                                statusFilters.length !== 0 ||
                                tokensFilter.length !== 0 ||
                                collectiblesFilter.length !== 0 ||
                                recentsFilters.length !== 0 ||
                                savedAddressFilters.length !== 0

    readonly property QtObject _d: QtObject {
        id: _d

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

    // Time filters
    property int selectedTime: Constants.TransactionTimePeriod.All
    property double fromTimestamp: activityController.status.startTimestamp * 1000
    property double toTimestamp: new Date().valueOf()
    function setSelectedTimestamp(selcTime) {
        selectedTime = selcTime
        switch(selectedTime) {
        case Constants.TransactionTimePeriod.All:
            fromTimestamp = 0
            toTimestamp = 0
            break
        case Constants.TransactionTimePeriod.Today:
            let dt = new Date()
            fromTimestamp = dt.setHours(0,0,0,0).valueOf() // Today
            dt.setDate(dt.getDate() + 1) // next day...
            dt.setHours(0, 0, 0, -1) // ... but just 1ms before midnight -> whole day included
            toTimestamp = dt.valueOf()
            break
        case Constants.TransactionTimePeriod.Yesterday:
            let dt1 = new Date()
            dt1.setDate(dt1.getDate() - 1)
            dt1.setHours(0, 0, 0, 0)
            fromTimestamp = dt1.valueOf() // Yesterday
            dt1.setDate(dt1.getDate() + 1)
            dt1.setHours(0, 0, 0, -1)
            toTimestamp = dt1.valueOf()
            break
        case Constants.TransactionTimePeriod.ThisWeek:
            let dt2 = LocaleUtils.getFirstDayOfTheCurrentWeek()
            dt2.setHours(0, 0, 0, 0)
            fromTimestamp = dt2.valueOf() // First day of this week
            toTimestamp = new Date().valueOf() // Today
            break
        case Constants.TransactionTimePeriod.LastWeek:
            let dt3 = LocaleUtils.getFirstDayOfTheCurrentWeek()
            dt3.setDate(dt3.getDate() - 7)
            dt3.setHours(0, 0, 0, 0)
            fromTimestamp = dt3.valueOf() // First day of last week
            dt3.setDate(dt3.getDate() + 6)
            dt3.setHours(23, 59, 59, 0)
            toTimestamp = dt3.valueOf() // Last day of last week
            break
        case Constants.TransactionTimePeriod.ThisMonth:
            let dt4 = new Date()
            dt4.setDate(1)
            dt4.setHours(0, 0, 0, 0)
            fromTimestamp = dt4.valueOf() // This month
            toTimestamp = new Date().valueOf()
            break
        case Constants.TransactionTimePeriod.LastMonth:
            let dt5 = new Date()
            dt5.setDate(1)
            dt5.setMonth(dt5.getMonth()-1)
            dt5.setHours(0, 0, 0, 0)
            fromTimestamp = dt5.valueOf() // Last month
            dt5.setDate(new Date(dt5.getFullYear(), dt5.getMonth(), 0).getDate() + 2)
            dt5.setHours(0, 0, 0, -1)
            toTimestamp = dt5.valueOf()
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
        typeFilters = _d.toggleFilterState(typeFilters, type, allFiltersCount)
        // Set backend values
        activityController.setFilterType(JSON.stringify(typeFilters))
        activityController.updateFilter()
    }

    // Status Filters
    property var statusFilters: []
    function toggleStatus(status, allFiltersCount) {
        // update filters
        statusFilters = _d.toggleFilterState(statusFilters, status, allFiltersCount)
        // Set backend values
        activityController.setFilterStatus(JSON.stringify(statusFilters))
        activityController.updateFilter()
    }

    // Tokens Filters
    property var tokensList: walletSectionAssets.assets
    property var tokensFilter: []
    function toggleToken(symbol) {
        // update filters
        tokensFilter = _d.toggleFilterState(tokensFilter, symbol, tokensList.count)
        // Set backend values
        activityController.setFilterAssets(JSON.stringify(tokensFilter), false)
        activityController.updateFilter()
    }

    // Collectibles Filters
    property var collectiblesList: walletSectionCollectibles.model
    property var collectiblesFilter: []
    function toggleCollectibles(id) {
        // update filters
        collectiblesFilter = _d.toggleFilterState(collectiblesFilter, id, collectiblesList.count)
        // TODO go side filtering is pending
        //      activityController.setFilterCollectibles(JSON.stringify(collectiblesFilter))
        //      activityController.updateFilter()
    }


    property var recentsList: activityController.recipientsModel
    property bool loadingRecipients: activityController.status.loadingRecipients
    property var recentsFilters: []
    function updateRecipientsModel() {
        activityController.updateRecipientsModel()
    }
    function toggleRecents(address) {
        // update filters
        recentsFilters = _d.toggleFilterState(recentsFilters, address, recentsList.count)
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
        savedAddressFilters = _d.toggleFilterState(savedAddressFilters, address, savedAddressList.count)
        // Set backend values
        activityController.setFilterToAddresses(JSON.stringify(recentsFilters.concat(savedAddressFilters)))
        activityController.updateFilter()
    }

    function updateFilterBase() {
        activityController.updateFilterBase()
    }

    function applyAllFilters() {
        activityController.setFilterTime(fromTimestamp/1000, toTimestamp/1000)
        activityController.setFilterType(JSON.stringify(typeFilters))
        activityController.setFilterStatus(JSON.stringify(statusFilters))
        activityController.setFilterAssets(JSON.stringify(tokensFilter), false)
        activityController.setFilterToAddresses(JSON.stringify(recentsFilters.concat(savedAddressFilters)))
        // TODO call update filter for collectibles

        activityController.updateFilter()
    }

    function resetAllFilters() {
        selectedTime = Constants.TransactionTimePeriod.All
        fromTimestamp = activityController.status.startTimestamp * 1000
        toTimestamp = new Date().valueOf()
        typeFilters = []
        statusFilters = []
        tokensFilter = []
        collectiblesFilter = []
        recentsFilters = []
        savedAddressFilters = []
        // TODO reset filter for collectibles

        applyAllFilters()
    }
}
