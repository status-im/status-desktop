import QtQuick 2.15

import utils 1.0

/*!
    \qmltype CollectibleObject
    \inherits TokenObject
    \brief ERC721 token object properties definition (also known as collectible).
*/
TokenObject {
    property bool transferable: false
    property bool remotelyDestruct: true
    property int remotelyDestructState: Constants.ContractTransactionStatus.None

    function copyCollectible(tokenObject) {
        copyToken(tokenObject)
        transferable = tokenObject.transferable
        remotelyDestruct = tokenObject.remotelyDestruct
        remotelyDestructState = tokenObject.remotelyDestructState
    }
}
