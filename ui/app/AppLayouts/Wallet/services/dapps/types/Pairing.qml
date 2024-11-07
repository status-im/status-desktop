pragma Singleton

import QtQml 2.15

QtObject {
    readonly property QtObject errors: QtObject {
        readonly property int notChecked: 0
        readonly property int uriOk: 1
        readonly property int tooCool: 2
        readonly property int invalidUri: 3
        readonly property int alreadyUsed: 4
        readonly property int expired: 5
        readonly property int unsupportedNetwork: 6
        readonly property int unknownError: 7
        readonly property int dappReadyForApproval: 8
        readonly property int userRejected: 9
        readonly property int rejectFailed: 10
    }
}