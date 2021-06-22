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
    
    property alias errorMessage: txtValidationError.text
    property var selectedAccount
    property double selectedAmount
    property var selectedAsset
    property double selectedGasEthValue
    property bool isValid: false

    onSelectedAccountChanged: validate()
    onSelectedAmountChanged: validate()
    onSelectedAssetChanged: validate()
    onSelectedGasEthValueChanged: validate()

    function validate() {
        let isValid = true
        if (!(selectedAccount && selectedAccount.assets && selectedAsset && selectedGasEthValue > 0)) {
            return root.isValid
        }
        isValid = true
        let gasTotal = selectedGasEthValue
        if (selectedAsset && selectedAsset.symbol && selectedAsset.symbol.toUpperCase() === "ETH") {
            gasTotal += selectedAmount
        }
        const currAcctGasAsset = Utils.findAssetBySymbol(selectedAccount.assets, "ETH")
        if (currAcctGasAsset && currAcctGasAsset.value < gasTotal) {
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
        //% "Not enough ETH for gas"
        text: qsTrId("wallet-insufficient-gas")
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 13
        height: 18
        color: Style.current.danger
    }
}
