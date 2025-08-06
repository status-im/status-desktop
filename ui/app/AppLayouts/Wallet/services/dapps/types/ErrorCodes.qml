pragma Singleton
import QtQuick

QtObject {
    // Maps to https://eips.ethereum.org/EIPS/eip-1193#rpc-errors
    readonly property QtObject rpcErrors: QtObject {
        readonly property int userRejectedRequest: 4001
        readonly property int unauthorized: 4100
        readonly property int unsupportedMethod: 4200
        readonly property int disconnected: 4900
        readonly property int chainDisconnected: 4901
    }
}