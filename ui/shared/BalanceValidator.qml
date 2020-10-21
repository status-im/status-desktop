import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "./status"

IconButton {
    id: root
    property var account
    property double amount
    property var asset
    property bool isValid: true
    property var reset: function() {}
    clickable: false
    width: 13.33
    height: 13.33
    iconWidth: width
    iconHeight: height    
    iconName: "exclamation_outline"
    color: Style.current.transparent
    visible: !isValid

    onAccountChanged: validate()
    onAmountChanged: validate()
    onAssetChanged: validate()

    function resetInternal() {
        account = undefined
        amount = 0
        asset = undefined
        isValid = true
    }

    function validate() {
        let isValid = true
        if (!(account && account.assets && asset && amount > 0)) {
            return root.isValid
        }
        const currAcctAsset = Utils.findAssetBySymbol(account.assets, asset.symbol)
        
        if (currAcctAsset && currAcctAsset.value < amount) {
            isValid = false
        }
        root.isValid = isValid
        return isValid
    }

    StatusToolTip {
        id: tooltip
        visible: parent.hovered
        width: 100
        text: qsTr("Insufficient balance")
    }
}
