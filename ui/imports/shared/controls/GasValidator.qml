import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import "../status"
import "../"
import "../panels"

// TODO: use StatusQ components here
Column {
    id: root

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
        let isValid = false
        if (!(selectedAccount && selectedAccount.assets && selectedAsset && selectedGasEthValue > 0)) {
            return root.isValid
        }
        let gasTotal = selectedGasEthValue
        if (selectedAsset && selectedAsset.symbol && selectedAsset.symbol.toUpperCase() === "ETH") {
            gasTotal += selectedAmount
        }
        const chainId = selectedNetwork && selectedNetwork.chainId

        const currAcctGasAsset = Utils.findAssetByChainAndSymbol(chainId, selectedAccount.assets, "ETH")
        if (currAcctGasAsset && currAcctGasAsset.totalBalance > gasTotal) {
            isValid = true
        }
        root.isValid = isValid
        return isValid
    }
    StatusIcon {
        anchors.horizontalCenter: parent.horizontalCenter
        height: 20
        width: 20
        icon: "cancel"
        color: Theme.palette.dangerColor1
    }
    StyledText {
        id: txtValidationError
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Not enough ETH for gas")
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 13
        height: 18
        color: Style.current.danger
    }
}
