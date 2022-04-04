import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import "../status"
import "../"
import "../panels"

// TODO: use StatusQ components here
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
    property var selectedNetwork
    property bool isValid: false

    onSelectedAccountChanged: validate()
    onSelectedAmountChanged: validate()
    onSelectedAssetChanged: validate()
    onSelectedGasEthValueChanged: validate()
    onSelectedNetworkChanged: validate()

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
        const chainId = (selectedNetwork && selectedNetwork.chainId) || Global.currentChainId

        const currAcctGasAsset = Utils.findAssetByChainAndSymbol(chainId, selectedAccount.assets, "ETH")
        if (currAcctGasAsset && currAcctGasAsset.totalBalance < gasTotal) {
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
        source: Style.svg("exclamation_outline")
    }
    StyledText {
        id: txtValidationError
        text: qsTr("Not enough ETH for gas")
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 13
        height: 18
        color: Style.current.danger
    }
}
