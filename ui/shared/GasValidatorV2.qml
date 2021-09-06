import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "./status"

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root
    visible: !isValid
    implicitHeight: 45
    color: Theme.palette.dangerColor2
    
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

    StatusBaseText {
        text: qsTr("The origin chain does not have enough gas to complete this transaction")
        font.weight: Font.Bold
        font.pixelSize: 13
        anchors.centerIn: parent
        color: Theme.palette.dangerColor1
    }
}

