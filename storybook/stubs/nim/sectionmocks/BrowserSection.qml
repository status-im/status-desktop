import QtQuick

// Required mock of: src/app/modules/main/browser_section/view.nim

Item {
    readonly property string contextPropertyName: "browserSection"

    readonly property QtObject activityController: QtObject {
        readonly property QtObject model: QtObject {
            readonly property int count: 0
            readonly property bool hasMore: false
        }
        readonly property QtObject status: QtObject {
            readonly property bool loadingData: false
            readonly property bool isFilterDirty: false
            readonly property bool newDataAvailable: false
            readonly property int errorCode: 0
        }

        function setFilterAddressesJson(addresses) {}
        function setFilterChainsJson(chains, allEnabled) {}
        function newFilterSession() {}
        function loadMoreItems() {}
        function updateFilter() {}
        function resetActivityData() {}
        function updateCollectiblesModel() {}
        function updateRecipientsModel() {}
    }
}
