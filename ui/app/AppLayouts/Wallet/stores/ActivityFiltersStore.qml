import QtQuick 2.13

import SortFilterProxyModel 0.2
import StatusQ.Core 0.1

import utils 1.0

QtObject {
    id: root

    property var transactionsList: walletSection.activityController.model

    property bool autoUpdateFilter: true
    property var activityController: walletSection.activityController
    readonly property bool filtersSet: selectedTime !== Constants.TransactionTimePeriod.All ||
                                typeFilters.length !== 0 ||
                                statusFilters.length !== 0 ||
                                tokensFilter.length !== 0 ||
                                collectiblesFilter.length !== 0 ||
                                recentsFilters.length !== 0 ||
                                savedAddressFilters.length !== 0

    readonly property QtObject _d: QtObject {
        id: d

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

        property bool fromTimestampNoLimit: true
        property bool toTimestampNoLimit: true

        function setFromTimestamp(value) {
            root.fromTimestamp = value
            fromTimestampNoLimit = false
        }
        function resetFromTimestamp() {
            root.fromTimestamp = 0
            fromTimestampNoLimit = true
        }

        function setToTimestamp(value) {
            root.toTimestamp = value
            toTimestampNoLimit = false
        }

        function resetToTimestamp() {
            root.toTimestamp = 0
            toTimestampNoLimit = true
        }
    }

    // Time filters
    property int selectedTime: Constants.TransactionTimePeriod.All
    // If noLimitTimestamp or double timestamp value otherwise
    property double fromTimestamp: 0
    property double toTimestamp: 0
    readonly property double currentActivityStartTimestamp: activityController.status.startTimestamp * 1000.0
    function setSelectedTimestamp(selcTime) {
        selectedTime = selcTime
        switch(selectedTime) {
        case Constants.TransactionTimePeriod.All:
            d.resetFromTimestamp()
            d.resetToTimestamp()
            break
        case Constants.TransactionTimePeriod.Today:
            let dt = new Date()
            d.setFromTimestamp(dt.setHours(0,0,0,0).valueOf()) // Today
            d.resetToTimestamp()
            break
        case Constants.TransactionTimePeriod.Yesterday:
            let dt1 = new Date()
            dt1.setDate(dt1.getDate() - 1)
            dt1.setHours(0, 0, 0, 0)
            d.setFromTimestamp(dt1.valueOf()) // Yesterday
            dt1.setDate(dt1.getDate() + 1)
            dt1.setHours(0, 0, 0, -1)
            d.setToTimestamp(dt1.valueOf())
            break
        case Constants.TransactionTimePeriod.ThisWeek:
            let dt2 = LocaleUtils.getFirstDayOfTheCurrentWeek()
            d.setFromTimestamp(dt2.setHours(0, 0, 0, 0).valueOf()) // First day of this week
            let dt3 = new Date()
            d.setToTimestamp(dt3.setHours(23,59,59,0).valueOf()) // Today
            d.toTimestampNoLimit = true
            break
        case Constants.TransactionTimePeriod.LastWeek:
            let dt4 = LocaleUtils.getFirstDayOfTheCurrentWeek()
            dt4.setDate(dt4.getDate() - 7)
            dt4.setHours(0, 0, 0, 0)
            d.setFromTimestamp(dt4.valueOf()) // First day of last week
            dt4.setDate(dt4.getDate() + 6)
            dt4.setHours(23, 59, 59, 0)
            d.setToTimestamp(dt4.valueOf()) // Last day of last week
            break
        case Constants.TransactionTimePeriod.ThisMonth:
            let dt5 = new Date()
            dt5.setDate(1)
            dt5.setHours(0, 0, 0, 0)
            d.setFromTimestamp(dt5.valueOf()) // This month
            let dt6 = new Date()
            d.setToTimestamp(dt6.setHours(23,59,59,0).valueOf()) // Today
            d.toTimestampNoLimit = true
            break
        case Constants.TransactionTimePeriod.LastMonth:
            let dt7 = new Date()
            dt7.setDate(1)
            dt7.setMonth(dt7.getMonth()-1)
            dt7.setHours(0, 0, 0, 0)
            d.setFromTimestamp(dt7.valueOf()) // Last month
            dt7.setDate(new Date(dt7.getFullYear(), dt7.getMonth(), 0).getDate() + 1)
            dt7.setHours(0, 0, 0, -1)
            d.setToTimestamp(dt7.valueOf())
            break
        default:
            return ""
        }

        applyTimeRange()
    }

    function setCustomTimeRange(fromTimestamp, toTimestamp) {
        d.setFromTimestamp(fromTimestamp)
        d.setToTimestamp(toTimestamp)

        applyTimeRange()
    }

    function applyTimeRange(callUpdate = true) {
        const startTimestamp = d.fromTimestampNoLimit
                            ? activityController.noLimitTimestamp
                            : fromTimestamp/1000
        const endTimestamp = d.toTimestampNoLimit
                            ? activityController.noLimitTimestamp
                            : toTimestamp/1000
        activityController.setFilterTime(startTimestamp, endTimestamp)
        if (autoUpdateFilter && callUpdate)
            activityController.updateFilter()
    }

    // Type Filters
    property var typeFilters: []
    function toggleType(type, allFiltersCount = 0) {
        // update filters
        typeFilters = d.toggleFilterState(typeFilters, type, allFiltersCount)
        // Set backend values
        activityController.setFilterType(JSON.stringify(typeFilters))
        if (autoUpdateFilter)
            activityController.updateFilter()
    }

    // Status Filters
    property var statusFilters: []
    function toggleStatus(status, allFiltersCount) {
        // update filters
        statusFilters = d.toggleFilterState(statusFilters, status, allFiltersCount)
        // Set backend values
        activityController.setFilterStatus(JSON.stringify(statusFilters))
        if (autoUpdateFilter)
            activityController.updateFilter()
    }

    // Tokens Filters
    property var tokensList: walletSectionAssets.assets
    property var tokensFilter: []
    function toggleToken(symbol) {
        // update filters
        tokensFilter = d.toggleFilterState(tokensFilter, symbol, tokensList.count)
        // Set backend values
        activityController.setFilterAssets(JSON.stringify(tokensFilter), false)
        if (autoUpdateFilter)
            activityController.updateFilter()
    }

    // Collectibles Filters
    property var collectiblesList: activityController.collectiblesModel
    property var collectiblesFilter: []
    property bool loadingCollectibles: activityController.status.loadingCollectibles
    function updateCollectiblesModel() {
        activityController.updateCollectiblesModel()
    }
    function loadMoreCollectibles() {
        activityController.loadMoreCollectibles()
    }
    function toggleCollectibles(uid) {
        // update filters
        collectiblesFilter = d.toggleFilterState(collectiblesFilter, uid, collectiblesList.count)
        // set backend values
        activityController.setFilterCollectibles(JSON.stringify(collectiblesFilter))
        if (autoUpdateFilter)
            activityController.updateFilter()
    }

    property var recentsList: activityController.recipientsModel
    property bool loadingRecipients: activityController.status.loadingRecipients
    property var recentsFilters: []
    function updateRecipientsModel() {
        activityController.updateRecipientsModel()
    }
    function toggleRecents(address) {
        // update filters
        recentsFilters = d.toggleFilterState(recentsFilters, address, recentsList.count)
        activityController.setFilterToAddresses(JSON.stringify(recentsFilters.concat(savedAddressFilters)))
        if (autoUpdateFilter)
            activityController.updateFilter()
    }

    function getChainShortNamesForSavedWalletAddress(address) {
        return walletSectionSavedAddresses.getChainShortNamesForAddress(address)
    }

    function getEnsForSavedWalletAddress(address) {
        return walletSectionSavedAddresses.getEnsForAddress(address)
    }

    property var savedAddressesModel: walletSectionSavedAddresses.model
    property bool areTestNetworksEnabled: networksModule.areTestNetworksEnabled
    property var savedAddressList: SortFilterProxyModel {
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
        savedAddressFilters = d.toggleFilterState(savedAddressFilters, address, savedAddressList.count)
        // Set backend values
        activityController.setFilterToAddresses(JSON.stringify(recentsFilters.concat(savedAddressFilters)))
        if (autoUpdateFilter)
            activityController.updateFilter()
    }

    function updateStartTimestamp() {
        activityController.updateStartTimestamp()
    }

    function applyAllFilters() {
        applyTimeRange(false)
        activityController.setFilterType(JSON.stringify(typeFilters))
        activityController.setFilterStatus(JSON.stringify(statusFilters))
        activityController.setFilterAssets(JSON.stringify(tokensFilter), false)
        activityController.setFilterToAddresses(JSON.stringify(recentsFilters.concat(savedAddressFilters)))
        activityController.setFilterCollectibles(JSON.stringify(collectiblesFilter))

        if (autoUpdateFilter)
            activityController.updateFilter()
    }

    function resetAllFilters() {
        selectedTime = Constants.TransactionTimePeriod.All
        d.resetFromTimestamp()
        d.resetToTimestamp()
        typeFilters = []
        statusFilters = []
        tokensFilter = []
        collectiblesFilter = []
        recentsFilters = []
        savedAddressFilters = []

        applyAllFilters()
    }
}
