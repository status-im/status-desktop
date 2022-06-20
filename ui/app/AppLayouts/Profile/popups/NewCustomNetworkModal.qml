import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import shared.status 1.0
import shared.controls 1.0

import StatusQ.Popups 0.1
import StatusQ.Controls 0.1

StatusModal {
    id: addNetworkPopup
    //% "Add network"
    header.title: qsTrId("add-network")
    height: Style.dp(644)

    property var advancedStore

    property string nameValidationError: ""
    property string rpcValidationError: ""
    property string networkValidationError: ""
    property int networkId: 1;
    property string networkType: Constants.networkMainnet

    function validate() {
        nameValidationError = ""
        rpcValidationError = ""
        networkValidationError = "";

        if (nameInput.text === "") {
            //% "You need to enter a name"
            nameValidationError = qsTrId("you-need-to-enter-a-name")
        }

        if (rpcInput.text === "") {
            //% "You need to enter the RPC endpoint URL"
            rpcValidationError = qsTrId("you-need-to-enter-the-rpc-endpoint-url")
        } else if(!Utils.isURL(rpcInput.text)) {
            //% "Invalid URL"
            rpcValidationError = qsTrId("invalid-url")
        }

        if (customRadioBtn.checked) {
            if (networkInput.text === "") {
                //% "You need to enter the network id"
                networkValidationError = qsTrId("you-need-to-enter-the-network-id")
            } else if (isNaN(networkInput.text)){
                //% "Should be a number"
                networkValidationError = qsTrId("should-be-a-number");
            } else if (parseInt(networkInput.text, 10) <= 4){
                //% "Invalid network id"
                networkValidationError = qsTrId("invalid-network-id");
            }
        }
        return !nameValidationError && !rpcValidationError && !networkValidationError
    }

    onOpened: {
        nameInput.text = "";
        rpcInput.text = "";
        networkInput.text = "";
        mainnetRadioBtn.checked = true;
        addNetworkPopup.networkId = 1;
        addNetworkPopup.networkType = Constants.networkMainnet;

        nameValidationError = "";
        rpcValidationError = "";
        networkValidationError = "";
    }

    rightButtons: [
        StatusButton {
            //% "Save"
            text: qsTrId("save")
            enabled: nameInput.text !== "" && rpcInput.text !== ""
            onClicked: {
                if (!addNetworkPopup.validate()) {
                    return;
                }

                if (customRadioBtn.checked){
                    addNetworkPopup.networkId = parseInt(networkInput.text, 10);
                }

                addNetworkPopup.advancedStore.addCustomNetwork(nameInput.text,
                                                               rpcInput.text,
                                                               addNetworkPopup.networkId,
                                                               addNetworkPopup.networkType)
                addNetworkPopup.close()
            }
        }
    ]

    contentItem: Item {
        anchors.fill: parent
        anchors {
            topMargin: (Style.current.padding + addNetworkPopup.topPadding)
            leftMargin: Style.current.padding
            rightMargin: Style.current.padding
            bottomMargin: (Style.current.padding + addNetworkPopup.bottomPadding)
        }
        Input {
            id: nameInput
            //% "Name"
            label: qsTrId("name")
            //% "Specify a name"
            placeholderText: qsTrId("specify-name")
            validationError: addNetworkPopup.nameValidationError
        }

        Input {
            id: rpcInput
            //% "RPC URL"
            label: qsTrId("rpc-url")
            //% "Specify a RPC URL"
            placeholderText: qsTrId("specify-rpc-url")
            validationError: addNetworkPopup.rpcValidationError
            anchors.top: nameInput.bottom
            anchors.topMargin: Style.current.padding
        }

        StatusSectionHeadline {
            id: networkChainHeadline
            //% "Network chain"
            text: qsTrId("network-chain")
            anchors.top: rpcInput.bottom
            anchors.topMargin: Style.current.padding
        }

        Column {
            id: radioButtonsColumn
            anchors.top: networkChainHeadline.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            anchors.leftMargin: Style.current.padding
            spacing: 0

            ButtonGroup {
                id: networkChainGroup
            }

            RadioButtonSelector {
                id: mainnetRadioBtn
                //% "Main network"
                objectName: "main"
                title: qsTrId("mainnet-network")
                buttonGroup: networkChainGroup
                checked: true
                onCheckedChanged: {
                    if (checked) {
                        addNetworkPopup.networkId = 1;
                        addNetworkPopup.networkType = Constants.networkMainnet;
                    }
                }
            }

            RadioButtonSelector {
                //% "Ropsten test network"
                title: qsTrId("ropsten-network")
                buttonGroup: networkChainGroup
                onCheckedChanged: {
                    if (checked) {
                        addNetworkPopup.networkId = 3;
                        addNetworkPopup.networkType = Constants.networkRopsten;
                    }
                }
            }

            RadioButtonSelector {
                //% "Rinkeby test network"
                title: qsTrId("rinkeby-network")
                buttonGroup: networkChainGroup
                onCheckedChanged: {
                    if (checked) {
                        addNetworkPopup.networkId = 4;
                        addNetworkPopup.networkType = Constants.networkRinkeby;
                    }
                }
            }

            RadioButtonSelector {
                id: customRadioBtn
                //% "Custom"
                objectName: "custom"
                title: qsTrId("custom")
                buttonGroup: networkChainGroup
                onCheckedChanged: {
                    if (checked) {
                        addNetworkPopup.networkType = "";
                    }
                    networkInput.visible = checked;
                }
            }
        }

        Input {
            id: networkInput
            anchors.top: radioButtonsColumn.bottom
            anchors.topMargin: Style.current.halfPadding
            visible: false
            //% "Network Id"
            label: qsTrId("network-id")
            //% "Specify the network id"
            placeholderText: qsTrId("specify-the-network-id")
            validationError: addNetworkPopup.networkValidationError
        }
    }
}
