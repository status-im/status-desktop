import QtQuick 2.15

import utils 1.0

/*!
    \qmltype TokenObject
    \inherits QtObject
    \brief Token object properties definition.
*/
QtObject {
    property int type: Constants.TokenType.ERC20

    // Special token (Owner and TMaster tokens):
    property bool isPrivilegedToken: false
    property bool isOwner: false
    property color color

    // Unique identifier:
    property string key

    // General descriptive properties:
    property string name
    property string symbol
    property string description
    property bool infiniteSupply: true
    property int supply: 1
    property int remainingTokens: supply

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

    // Collectible-specific properties:
    property bool transferable: false
    property bool remotelyDestruct: true
    property int remotelyDestructState: Constants.ContractTransactionStatus.None

    // Asset-specific properties:
    property int decimals: 2
}
