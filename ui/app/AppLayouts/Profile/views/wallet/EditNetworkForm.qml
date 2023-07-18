import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared.panels 1.0
import utils 1.0

ColumnLayout {
    id: root

    property var network
    property var networksModule
    signal evaluateRpcEndPoint(string url)
    signal updateNetworkValues(int chainId, string newMainRpcInput, string newFailoverRpcUrl)

    enum EvaluationState {
        UnTouched,
        Pending,
        Verified,
        InvalidURL,
        PingUnsuccessful
    }

    QtObject {
        id: d
        property int evaluationStatus: EditNetworkForm.UnTouched
        property int evaluationStatusFallBackRpc: EditNetworkForm.UnTouched
        property var evaluateRpcEndPoint: Backpressure.debounce(root, 400, function (value) {
            if(!Utils.isURL(value)) {
                if(value === mainRpcInput.text) {
                    d.evaluationStatus = EditNetworkForm.InvalidURL
                }
                else if(value === failoverRpcUrlInput.text) {
                    d.evaluationStatusFallBackRpc = EditNetworkForm.InvalidURL
                }
                return
            }
            root.evaluateRpcEndPoint(value)
        })

        function revertValues() {
            warningCheckbox.checked = false
            d.evaluationStatus = EditNetworkForm.UnTouched
            d.evaluationStatusFallBackRpc = EditNetworkForm.UnTouched
            if(!!network) {
                mainRpcInput.text = network.rpcURL
                failoverRpcUrlInput.text = network.fallbackURL
            }
        }       

        function getUrlStatusText(status, text) {
            switch(status) {
            case EditNetworkForm.Pending:
                return qsTr("Checking RPC...")
            case EditNetworkForm.InvalidURL:
                return qsTr("What is %1? This isn’t a URL 😒").arg(text)
            case EditNetworkForm.PingUnsuccessful:
                return  qsTr("RPC appears to be either offline or this is not a valid JSON RPC endpoint URL")
            case EditNetworkForm.Verified:
                return qsTr("RPC successfully reached")
            default: return ""
            }
        }
    }

    onVisibleChanged: if(!visible) {d.revertValues()}

    Connections {
        target: networksModule
        function onChainIdFetchedForUrl(url, chainId, success) {
            let status = EditNetworkForm.PingUnsuccessful
            if(success) {
                status = EditNetworkForm.Verified
            }
            if(url === mainRpcInput.text) {
                d.evaluationStatus = status
            }
            else if(url === failoverRpcUrlInput.text) {
                d.evaluationStatusFallBackRpc = status
            }
        }
    }

    spacing: 20

    StatusInput {
        Layout.fillWidth: true
        label: qsTr("Network name")
        text: !!network ? network.chainName : ""
        input.enabled: false
    }

    StatusInput {
        Layout.fillWidth: true
        label: qsTr("Short name")
        text: !!network ? network.shortName : ""
        input.enabled: false
    }

    StatusInput {
        Layout.fillWidth: true
        label: qsTr("Chain ID")
        text: !!network ? network.chainId : ""
        input.enabled: false
    }

    StatusInput {
        Layout.fillWidth: true
        label: qsTr("Native Token Symbol")
        text: !!network ? network.nativeCurrencySymbol : ""
        input.enabled: false
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: childrenRect.height
        StatusBaseText {
            id: requiredText
            anchors.top: parent.top
            anchors.topMargin: 4
            anchors.right: parent.right
            elide: Text.ElideRight
            text: qsTr("Required")
            font.pixelSize: 12
            color: Theme.palette.baseColor1
        }
        StatusInput {
            id: mainRpcInput
            width: parent.width
            label: qsTr("Main JSON RPC URL")
            text: !!network ? network.rpcURL : ""
            onTextChanged: {
                if(!!text && text !== network.rpcURL) {
                    d.evaluationStatus = EditNetworkForm.Pending
                    Qt.callLater(d.evaluateRpcEndPoint, text);
                }
            }
            errorMessageCmp.horizontalAlignment: d.evaluationStatus === EditNetworkForm.Pending ||
                                                 d.evaluationStatus === EditNetworkForm.Verified ?
                                                     Text.AlignLeft: Text.AlignRight
            errorMessageCmp.visible: d.evaluationStatus !== EditNetworkForm.UnTouched
            errorMessageCmp.text: d.getUrlStatusText(d.evaluationStatus, text)
            errorMessageCmp.color: d.evaluationStatus === EditNetworkForm.Pending ?
                                       Theme.palette.baseColor1:
                                       d.evaluationStatus === EditNetworkForm.Verified ?
                                           Theme.palette.successColor1 : Theme.palette.dangerColor1
        }
    }

    StatusInput {
        id: failoverRpcUrlInput
        Layout.fillWidth: true
        label: qsTr("Failover JSON RPC URL")
        text: !!network ? network.fallbackURL : ""
        onTextChanged: {
            if(!!text && text !== network.fallbackURL) {
                d.evaluationStatusFallBackRpc = EditNetworkForm.Pending
                Qt.callLater(d.evaluateRpcEndPoint, text);
            }
        }
        errorMessageCmp.horizontalAlignment: d.evaluationStatusFallBackRpc === EditNetworkForm.Pending ||
                                             d.evaluationStatusFallBackRpc === EditNetworkForm.Verified ?
                                                 Text.AlignLeft: Text.AlignRight
        errorMessageCmp.visible: d.evaluationStatusFallBackRpc !== EditNetworkForm.UnTouched
        errorMessageCmp.text: d.getUrlStatusText(d.evaluationStatusFallBackRpc, text)
        errorMessageCmp.color: d.evaluationStatusFallBackRpc === EditNetworkForm.Pending ?
                                   Theme.palette.baseColor1:
                                   d.evaluationStatusFallBackRpc === EditNetworkForm.Verified ?
                                       Theme.palette.successColor1 : Theme.palette.dangerColor1

    }

    StatusInput {
        Layout.fillWidth: true
        label: qsTr("Block Explorer")
        text: !!network ? network.blockExplorerURL : ""
        input.enabled: false
    }

    StatusCheckBox {
        id: warningCheckbox
        Layout.fillWidth: true
        text: qsTr("I understand that changing network settings can cause unforeseen issues, errors, security risks and potentially even loss of funds.")
        checkState: Qt.Unchecked
        font.pixelSize: 15
    }

    Separator {}

    Row {
        Layout.alignment: Qt.AlignRight
        spacing: 8
        StatusButton {
            text: qsTr("Revert to default")
            normalColor: "transparent"
            enabled: d.evaluationStatus !== EditNetworkForm.UnTouched || d.evaluationStatusFallBackRpc !== EditNetworkForm.UnTouched
            onClicked: d.revertValues()
        }
        StatusButton {
            text: qsTr("Save Changes")
            enabled: (d.evaluationStatus === EditNetworkForm.Verified || d.evaluationStatusFallBackRpc === EditNetworkForm.Verified) && warningCheckbox.checked
            onClicked: root.updateNetworkValues(network.chainId, mainRpcInput.text, failoverRpcUrlInput.text)
        }
    }
}
