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
    signal evaluateRpcEndPoint(string url, bool isMainUrl)
    signal updateNetworkValues(int chainId, string newMainRpcInput, string newFailoverRpcUrl)

    enum EvaluationState {
        UnTouched,
        Pending,
        Verified,
        InvalidURL,
        PingUnsuccessful,
        SameAsOther,
        Empty
    }

    QtObject {
        id: d
        property int evaluationStatusMainRpc: EditNetworkForm.UnTouched
        property int evaluationStatusFallBackRpc: EditNetworkForm.UnTouched
        property var evaluateRpcEndPoint: Backpressure.debounce(root, 400, function (value, isMainUrl) {
            if(!Utils.isURL(value)) {
                if(isMainUrl)
                    d.evaluationStatusMainRpc = EditNetworkForm.InvalidURL
                else
                    d.evaluationStatusFallBackRpc = EditNetworkForm.InvalidURL
                return
            }
            root.evaluateRpcEndPoint(value, isMainUrl)
        })

        function revertValues() {
            warningCheckbox.checked = false
            d.evaluationStatusMainRpc = EditNetworkForm.UnTouched
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
            case EditNetworkForm.SameAsOther:
                return qsTr("Main and failover JSON RPC URLs are the same")
            default: return ""
            }
        }

        function getErrorMessageColor(status) {
            switch(status) {
            case EditNetworkForm.Pending:
                return Theme.palette.baseColor1
            case EditNetworkForm.SameAsOther:
                return  Theme.palette.warningColor1
            case EditNetworkForm.Verified:
                return Theme.palette.successColor1
            default: return Theme.palette.dangerColor1
            }
        }

        function getErrorMessageAlignment(status) {
            switch(status) {
            case EditNetworkForm.Pending:
            case EditNetworkForm.Verified:
            case EditNetworkForm.SameAsOther:
                return  Text.AlignLeft
            default: return Text.AlignRight
            }
        }
    }

    onVisibleChanged: if(!visible) {d.revertValues()}

    Connections {
        target: networksModule
        function onChainIdFetchedForUrl(url, chainId, success, isMainUrl) {
            let status = EditNetworkForm.PingUnsuccessful
            if(success) {
                if((isMainUrl && url === network.fallbackURL) ||
                        (!isMainUrl && url === network.rpcURL)) {
                  status = EditNetworkForm.SameAsOther
                }
                else
                    status = EditNetworkForm.Verified
            }
            if(isMainUrl)
                d.evaluationStatusMainRpc = status
            else
                d.evaluationStatusFallBackRpc = status            
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
            text: {
                if (!network) {
                    return ""
                }
                if (network.originalRpcURL === network.rpcURL) {
                    return network.rpcURL.replace(/(.*\/).*/, '$1')
                }
                return network.rpcURL
            }
            onTextChanged: {
                if (text === "") {
                    d.evaluationStatusMainRpc = EditNetworkForm.Empty
                    return
                }
                if(!!text &&
                        (network.originalRpcURL === network.rpcURL && text !== network.rpcURL.replace(/(.*\/).*/, '$1')) ||
                        (network.originalRpcURL !== network.rpcURL && text !== network.rpcURL)) {
                    d.evaluationStatusMainRpc = EditNetworkForm.Pending
                    Qt.callLater(d.evaluateRpcEndPoint, text, true);
                }
            }
            errorMessageCmp.horizontalAlignment: d.getErrorMessageAlignment(d.evaluationStatusMainRpc)
            errorMessageCmp.visible: d.evaluationStatusMainRpc !== EditNetworkForm.UnTouched

            errorMessageCmp.color: d.getErrorMessageColor(d.evaluationStatusMainRpc)
            errorMessageCmp.text: {
                if (text === "") {
                    return qsTr("Main JSON RPC URL is required")
                }
                return d.getUrlStatusText(d.evaluationStatusMainRpc, text)
            }
        }
    }

    StatusInput {
        id: failoverRpcUrlInput
        Layout.fillWidth: true
        label: qsTr("Failover JSON RPC URL")
        text: {
            if (!network) {
                return ""
            }
            if (network.originalFallbackURL === network.fallbackURL) {
                return network.fallbackURL.replace(/(.*\/).*/, '$1')
            }
            return network.fallbackURL
        }
        onTextChanged: {
            if (text === "") {
                d.evaluationStatusFallBackRpc = EditNetworkForm.Empty
                return
            }

            if(!!text &&
                    (network.originalFallbackURL === network.fallbackURL && text !== network.fallbackURL.replace(/(.*\/).*/, '$1')) ||
                    (network.originalFallbackURL !== network.fallbackURL && text !== network.fallbackURL)) {
                d.evaluationStatusFallBackRpc = EditNetworkForm.Pending
                Qt.callLater(d.evaluateRpcEndPoint, text, false);
            }
        }
        errorMessageCmp.horizontalAlignment: d.getErrorMessageAlignment(d.evaluationStatusFallBackRpc)
        errorMessageCmp.visible: d.evaluationStatusFallBackRpc !== EditNetworkForm.UnTouched
        errorMessageCmp.text: d.getUrlStatusText(d.evaluationStatusFallBackRpc, text)
        errorMessageCmp.color: d.getErrorMessageColor(d.evaluationStatusFallBackRpc)
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
            enabled: d.evaluationStatusMainRpc !== EditNetworkForm.UnTouched || d.evaluationStatusFallBackRpc !== EditNetworkForm.UnTouched
            onClicked: d.revertValues()
        }
        StatusButton {
            text: qsTr("Save Changes")
            enabled: (
                d.evaluationStatusMainRpc === EditNetworkForm.Verified || 
                d.evaluationStatusFallBackRpc === EditNetworkForm.Verified || 
                d.evaluationStatusMainRpc === EditNetworkForm.SameAsOther || 
                d.evaluationStatusFallBackRpc === EditNetworkForm.SameAsOther ||
                d.evaluationStatusFallBackRpc === EditNetworkForm.Empty
                ) && warningCheckbox.checked

            onClicked: root.updateNetworkValues(network.chainId, mainRpcInput.text, failoverRpcUrlInput.text)
        }
    }
}
