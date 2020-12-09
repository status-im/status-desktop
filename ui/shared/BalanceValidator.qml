import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "./status"

Column {
    id: root
    anchors.horizontalCenter: parent.horizontalCenter
    visible: !isValid
    spacing: 5

    property var account
    property double amount
    property var asset
    property bool isValid: false
    property alias errorMessage: txtValidationError.text

    onAccountChanged: validate()
    onAmountChanged: validate()
    onAssetChanged: validate()

    function validate() {
        let isValid = true
        if (!(account && account.assets && asset && amount >= 0)) {
            return root.isValid
        }
        const currAcctAsset = Utils.findAssetBySymbol(account.assets, asset.symbol)
        
        if (currAcctAsset && currAcctAsset.value < amount) {
            isValid = false
        }
        root.isValid = isValid
        return isValid
    }
    SVGImage {
        id: imgExclamation
        width: 13.33
        height: 13.33
        sourceSize.height: height * 2
        sourceSize.width: width * 2
        anchors.horizontalCenter: parent.horizontalCenter
        fillMode: Image.PreserveAspectFit
        source: "../app/img/exclamation_outline.svg"
    }
    StyledText {
        id: txtValidationError
        text: qsTr("Insufficient balance")
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 13
        height: 18
        color: Style.current.danger
    }
}
