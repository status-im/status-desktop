import QtQuick

// Mock of src/app/modules/shared_modules/connector/controller.nim

QtObject {
    signal connected(string payload)
    signal disconnected(string payload)
    signal connectorCallRPCResult(int requestId, string payload)
    signal chainIdSwitched(string payload)
    signal accountChanged(string payload)
    
    function getDApps() {
        return "[]"
    }
    
    function disconnect(hostname) {
        return false
    }
    
    function connectorCallRPC(requestId, payload) {
        // Mock
    }
    
    function changeAccount(origin, clientId, newAccount) {
        // Mock
    }
}

