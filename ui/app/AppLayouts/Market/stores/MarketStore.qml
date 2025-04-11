import QtQuick 2.15

QtObject {
    id: root

    readonly property var _marketModule: marketSection

    readonly property var marketLeaderboardModel: _marketModule.marketLeaderboardModel

    readonly property int currentPage: _marketModule.currentPage

    readonly property var totalLeaderboardCount: _marketModule.totalMarketLeaderboardModelCount

    readonly property var marketLeaderboardLoading: _marketModule.marketLeaderboardLoading

    function requestMarketTokenPage(pageNumber, pageSize, sortOrder) {
        _marketModule.requestMarketTokenPage(pageNumber, pageSize, sortOrder)
    }
}
