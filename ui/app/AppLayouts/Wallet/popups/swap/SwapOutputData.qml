import QtQuick 2.15

import utils 1.0

/* This is so that all the data from the response
to the swap request can be placed here at one place. */
QtObject {
    id: root

    property string fromTokenAmount: ""
    property string toTokenAmount: ""
    property real totalFees: 0
    property var bestRoutes: []
    property bool hasError
    property var rawPaths: []
    // need to check how this is done in new router v2, right now it is Enum type
    property int estimatedTime
    property string txProviderName
    property bool approvalNeeded
    property string approvalGasFees
    property string approvalAmountRequired
    property string approvalContractAddress

    function reset() {
        root.fromTokenAmount = ""
        root.toTokenAmount = ""
        root.resetAllButReceivedTokenValuesForSwap()
    }

    function resetAllButReceivedTokenValuesForSwap() {
        root.totalFees = 0
        root.bestRoutes = []
        root.approvalNeeded = false
        root.hasError = false
        root.rawPaths = []
        root.estimatedTime = Constants.TransactionEstimatedTime.Unknown
        txProviderName = ""
        approvalNeeded = false
        approvalGasFees = ""
        approvalAmountRequired = ""
        approvalContractAddress = ""
    }
}

