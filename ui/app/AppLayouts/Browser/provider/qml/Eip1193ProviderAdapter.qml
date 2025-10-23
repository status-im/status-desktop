import QtQuick 2.15

QtObject {
    id: root
    
    // ============================================================================
    // EIP-1193 PUBLIC PROPERTIES (exposed to JS via WebChannel)
    // ============================================================================
    readonly property bool isStatus: true
    readonly property bool isMetaMask: false
    property string chainId: "0x1"  // hex format for EIP-1193
    property string networkVersion: "1"  // decimal format (deprecated but used by some dApps)
    property string selectedAddress: ""  // current active address
    property var accounts: []
    property bool connected: false
    
    // ============================================================================
    // EIP-1193 EVENTS (for WebChannel)
    // ============================================================================
    
    signal connectEvent(var info)
    signal disconnectEvent(var error)
    signal accountsChangedEvent(var accounts)
    signal chainChangedEvent(string chainId)
    signal messageEvent(var message)
    signal requestCompletedEvent(var payload)

    // Internal
    signal providerStateChanged()  // re-read State
    
    // ============================================================================
    // EIP-1193 REQUEST METHOD STUB
    // ============================================================================
    function request(args) {
        console.error("[Eip1193ProviderAdapter] request() not injected - should be overridden by ConnectorBridge")
        return JSON.stringify({
            jsonrpc: "2.0",
            id: args && args.requestId || 0,
            error: { code: -32603, message: "Request function not properly injected" }
        })
    }
}
