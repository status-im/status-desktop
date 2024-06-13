import QtQuick 2.15

/* This is so that all the data from the response
to the swap request can be placed here at one place. */
QtObject {
    id: root

    property string fromTokenAmount: ""
    property string toTokenAmount: ""
    property real totalFees: 0
    property var bestRoutes: []
    property bool approvalNeeded
    property bool hasError
    property var rawPaths: []

    function reset() {
        root.fromTokenAmount = ""
        root.toTokenAmount = ""
        root.totalFees = 0
        root.bestRoutes = []
        root.approvalNeeded = false
        root.hasError = false
        root.rawPaths = []
    }
}

