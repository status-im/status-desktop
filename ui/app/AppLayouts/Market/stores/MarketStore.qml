import QtQuick 2.15

QtObject {
    id: root

    readonly property var _marketModule: marketSection

    readonly property var marketLeaderboardModel: _marketModule.marketLeaderboardModel

    readonly property int currentPage: _marketModule.currentPage

    readonly property int totalLeaderboardCount: _marketModule.totalMarketLeaderboardModelCount

    readonly property bool marketLeaderboardLoading: _marketModule.marketLeaderboardLoading

    function requestMarketTokenPage(pageNumber, pageSize, sortOrder = 0) {
        _marketModule.requestMarketTokenPage(pageNumber, pageSize, sortOrder)
    }

    function unsubscribeFromUpdates() {
        _marketModule.unsubscribeFromUpdates()
    }
}
