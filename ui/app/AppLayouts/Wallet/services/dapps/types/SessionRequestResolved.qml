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

    required property string topic
    required property string id
    required property string method

    required property var account
    required property var network

    required property var data

    readonly property alias dappName: d.dappName
    readonly property alias dappUrl: d.dappUrl
    readonly property alias dappIcon: d.dappIcon

    readonly property string maxFeesText: ""
    readonly property string estimatedTimeText: ""

    function resolveDappInfoFromSession(session) {
        let meta = session.peer.metadata
        d.dappName = meta.name
        d.dappUrl = meta.url
        if (meta.icons && meta.icons.length > 0) {
            d.dappIcon = meta.icons[0]
        }
    }

    // dApp info
    QtObject {
        id: d

        property string dappName
        property string dappUrl
        property url dappIcon
    }
}