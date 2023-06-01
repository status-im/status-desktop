import QtQuick 2.15

import utils 1.0

/*!
    \qmltype TokenObject
    \inherits QtObject
    \brief Token object properties definition.
*/
QtObject {
    // Unique identifier:
    property string key

    // General descriptive properties:
    property string name
    property string symbol
    property string description
    property bool infiniteSupply: true
    property int supply: 1
    property int remainingTokens

    // Artwork related properties:
    property url artworkSource
    property rect artworkCropRect: Qt.rect(0, 0, 0, 0)

    // Network related properties:
    property int chainId
    property string chainName
    property string chainIcon

    // Account related properties (from where they will be / have been deployed):
    property string accountAddress
    property string accountName

    // Contract transactions states:
    property int deployState: Constants.ContractTransactionStatus.None
    property int burnState: Constants.ContractTransactionStatus.None

    function copyToken(tokenObject) {
        key = tokenObject.key
        name = tokenObject.name
        symbol = tokenObject.symbol
        description = tokenObject.description
        infiniteSupply = tokenObject.infiniteSupply
        supply = tokenObject.supply
        remainingTokens = tokenObject.remainingTokens
        artworkSource = tokenObject.artworkSource
        artworkCropRect = tokenObject.artworkCropRect
        chainId = tokenObject.chainId
        chainName = tokenObject.chainName
        chainIcon = tokenObject.chainIcon
        accountAddress = tokenObject.accountAddress
        accountName = tokenObject.accountName
        deployState = tokenObject.deployState
        burnState = tokenObject.burnState
    }
}
