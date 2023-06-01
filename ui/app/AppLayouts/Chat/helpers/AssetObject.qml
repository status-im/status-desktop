import QtQuick 2.15

/*!
    \qmltype AssetObject
    \inherits TokenObject
    \brief ERC20 token object properties definition (also known as asset).
*/
TokenObject {
    property int decimals: 2 // Default value

    function copyAsset(tokenObject) {
        copyToken(tokenObject)
        decimals = tokenObject.decimals
    }
}
