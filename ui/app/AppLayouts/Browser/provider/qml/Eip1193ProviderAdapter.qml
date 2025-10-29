import QtQuick
import QtWebChannel

QtObject {
    id: root

    // EIP-1193 PUBLIC PROPERTIES
    readonly property bool isStatus: true
    readonly property bool isMetaMask: false
    property string chainId: "0x1"  // hex format for EIP-1193
    property string networkVersion: "1"  // decimal format (deprecated but used by some dApps)
    property string selectedAddress: ""  // current active address
    property var accounts: []
    property bool connected: false

    // EIP-1193 EVENTS (for WebChannel)
    signal connectEvent(var info)
    signal disconnectEvent(var error)
    signal accountsChangedEvent(var accounts)
    signal chainChangedEvent(string chainId)
    signal messageEvent(var message)
    signal requestCompletedEvent(var payload)
    signal requestInternal(var args)

    // Internal
    signal providerStateChanged()  // re-read State

    // EIP-1193 REQUEST METHOD STUB
    function request(args) {
        requestInternal(args)
        // Return immediately - async response comes via requestCompletedEvent
        return { jsonrpc: "2.0", id: args.requestId || 0, result: null }
    }
}
