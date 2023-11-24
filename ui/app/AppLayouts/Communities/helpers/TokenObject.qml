import QtQuick 2.15

import utils 1.0

/*!
    \qmltype TokenObject
    \inherits QtObject
    \brief Token object properties definition.
*/
QtObject {
    property int type: Constants.TokenType.ERC20
    property int privilegesLevel: Constants.TokenPrivilegesLevel.Community
    readonly property bool isPrivilegedToken: (privilegesLevel === Constants.TokenPrivilegesLevel.Owner) ||
                                              (privilegesLevel === Constants.TokenPrivilegesLevel.TMaster)
    property color color // Owner and TMaster icon color

    // Unique identifier:
    property string key

    // General descriptive properties:
    property string name
    property string symbol
    property string description
    property bool infiniteSupply: true
    property string supply: "1"
    property string remainingTokens: supply
    property int multiplierIndex: 0

    // Artwork related properties:
    property url artworkSource
    property rect artworkCropRect: Qt.rect(0, 0, 0, 0)

    // Network related properties:
    property int chainId
    property string chainName
    property string chainIcon
    property string tokenAddress

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
