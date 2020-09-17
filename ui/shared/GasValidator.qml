import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "./"

Item {
    id: root
    anchors.left: parent.left
    anchors.right: parent.right
    height: colValidation.height
    //% "Not enough ETH for gas"
    property string notEnoughEthForGasMessage: qsTrId("wallet-insufficient-gas")
    property var selectedAccount
    property double selectedAmount
    property var selectedAsset
    property double selectedGasEthValue
    property bool isValid: false
    property var reset: function() {}

    onSelectedAccountChanged: validate()
    onSelectedAmountChanged: validate()
    onSelectedAssetChanged: validate()
    onSelectedGasEthValueChanged: validate()

    function resetInternal() {
        selectedAccount = undefined
        selectedAmount = 0
        selectedAsset = undefined
        selectedGasEthValue = 0
        isValid = true
    }

    function validate() {
        let isValid = true
        if (!(selectedAccount && selectedAccount.assets && selectedAsset && selectedGasEthValue > 0)) {
            return root.isValid
        }
        txtValidationError.text = ""
        let gasTotal = selectedGasEthValue
        if (selectedAsset && selectedAsset.symbol && selectedAsset.symbol.toUpperCase() === "ETH") {
            gasTotal += selectedAmount
        }
        const currAcctGasAsset = Utils.findAssetBySymbol(selectedAccount.assets, "ETH")
        if (currAcctGasAsset.value < gasTotal) {
            isValid = false
            txtValidationError.text = notEnoughEthForGasMessage
        }
        root.isValid = isValid
        return isValid
    }

    Column {
        id: colValidation
        anchors.horizontalCenter: parent.horizontalCenter
        visible: txtValidationError.text !== ""
        spacing: 5

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
            text: ""
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 13
            height: 18
            color: Style.current.danger
        }
    }
}
