import QtQuick 2.15

import StatusQ.Core.Utils 0.1

QObject {
    id: root

    /// An WalletConnect.session_request event data looks like this:
    /// {
    ///     topic,
    ///     params: {
    ///         request: [requestParamsMessage]
    ///     },
    ///     id
    /// }
    required property var event

    /// dApp request data
    required property string topic
    required property string requestId
    required property string method
    required property string accountAddress
    required property string chainId
    // optional expiry date in ms
    property var expirationTimestamp

    // Maps to Constants.DAppConnectors values
    required property int sourceId

    required property var data
    // Data prepared for display in a human readable format
    required property var preparedData

    property alias dappName: d.dappName
    property alias dappUrl: d.dappUrl
    property alias dappIcon: d.dappIcon

    /// extra data resolved from wallet
    property string maxFeesText: ""
    property string maxFeesEthText: ""
    property bool haveEnoughFunds: false
    property bool haveEnoughFees: false

    property var /* Big */ fiatMaxFees
    property var /* Big */ ethMaxFees
    property var feesInfo

    /// maps to Constants.TransactionEstimatedTime values
    property int estimatedTimeCategory: 0

    function resolveDappInfoFromSession(session) {
        let meta = session.peer.metadata
        d.dappName = meta.name
        d.dappUrl = meta.url
        if (meta.icons && meta.icons.length > 0) {
            d.dappIcon = meta.icons[0]
        }
    }

    function isExpired() {
        return !!expirationTimestamp && expirationTimestamp > 0 && Math.floor(Date.now() / 1000) >= expirationTimestamp
    }

    function setExpired() {
        expirationTimestamp = Math.floor(Date.now() / 1000)
    }

    // dApp info
    QtObject {
        id: d

        property string dappName
        property string dappUrl
        property url dappIcon
        property bool hasExpiry
    }
}