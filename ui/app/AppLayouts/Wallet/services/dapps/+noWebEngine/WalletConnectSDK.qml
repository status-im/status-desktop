import QtQuick

/*
    Dummy WalletConnectSDK.qml file to avoid WebEngine dependency
    Preserves the same API as WalletConnectSDK.qml
*/

WalletConnectSDKBase {
    id: root

    readonly property bool sdkReady: false

    property string userUID: ""
    property url url: ""
}
