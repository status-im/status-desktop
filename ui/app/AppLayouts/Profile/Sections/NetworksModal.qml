import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    id: popup
    //% "Network"
    title: qsTrId("network")

    property string newNetwork: "";
 
    ScrollView {
        id: svNetworks
        width: parent.width
        height: 300
        clip: true

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOn

        Column {
            id: column
            spacing: Style.current.padding
            width: parent.width

            ButtonGroup { id: networkSettings }

            Item {
                id: addNetwork
                width: parent.width
                height: addButton.height

                StatusRoundButton {
                    id: addButton
                    icon.name: "plusSign"
                    size: "medium"
                    type: "secondary"
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    id: usernameText
                    //% "Add network"
                    text: qsTrId("add-network")
                    color: Style.current.blue
                    anchors.left: addButton.right
                    anchors.leftMargin: Style.current.padding
                    anchors.verticalCenter: addButton.verticalCenter
                    font.pixelSize: 15
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: addNetworkPopup.open()
                }

                ModalPopup {
                    id: addNetworkPopup
                    //% "Add network"
                    title: qsTrId("add-network")
                    height: 650

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

                    footer: StatusButton {
                        anchors.right: parent.right
                        anchors.rightMargin: Style.current.smallPadding
                        //% "Save"
                        text: qsTrId("save")
                        anchors.bottom: parent.bottom
                        enabled: nameInput.text !== "" && rpcInput.text !== ""
                        onClicked: {
                            if (!addNetworkPopup.validate()) {
                                return;
                            }

                            if (customRadioBtn.checked){
                                addNetworkPopup.networkId = parseInt(networkInput.text, 10);
                            }

                            profileModel.network.add(nameInput.text, rpcInput.text, addNetworkPopup.networkId, addNetworkPopup.networkType)
                            profileModel.network.reloadCustomNetworks();
                            addNetworkPopup.close()
                        }
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
                        anchors.topMargin: Style.current.bigPadding
                    }

                    StatusSectionHeadline {
                        id: networkChainHeadline
                        //% "Network chain"
                        text: qsTrId("network-chain")
                        anchors.top: rpcInput.bottom
                        anchors.topMargin: Style.current.bigPadding
                    }

                    Column {
                        spacing: Style.current.padding
                        anchors.top: networkChainHeadline.bottom
                        anchors.topMargin: Style.current.smallPadding
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: Style.current.padding
                        anchors.leftMargin: Style.current.padding

                        ButtonGroup {
                            id: networkChainGroup
                        }

                        StatusRadioButtonRow {
                            id: mainnetRadioBtn
                            text: qsTr("Main network")
                            buttonGroup: networkChainGroup
                            checked: true
                            onRadioCheckedChanged: {
                                if (checked) {
                                    addNetworkPopup.networkId = 1;
                                    addNetworkPopup.networkType = Constants.networkMainnet;
                                }
                            }
                        }

                        StatusRadioButtonRow {
                            text: qsTr("Ropsten test network")
                            buttonGroup: networkChainGroup
                            onRadioCheckedChanged: {
                                if (checked) {
                                    addNetworkPopup.networkId = 3;
                                    addNetworkPopup.networkType = Constants.networkRopsten;
                                }
                            }
                        }

                        StatusRadioButtonRow {
                            text: qsTr("Rinkeby test network")
                            buttonGroup: networkChainGroup
                            onRadioCheckedChanged: {
                                if (checked) {
                                    addNetworkPopup.networkId = 4;
                                    addNetworkPopup.networkType = Constants.networkRinkeby;
                                }
                            }
                        }

                        StatusRadioButtonRow {
                            id: customRadioBtn
                            text: qsTr("Custom")
                            buttonGroup: networkChainGroup
                            onRadioCheckedChanged: {
                                if (checked) {
                                    addNetworkPopup.networkType = "";
                                }
                            }
                        }

                        Input {
                            id: networkInput
                            visible: customRadioBtn.checked
                            //% "Network Id"
                            label: qsTrId("network-id")
                            //% "Specify the network id"
                            placeholderText: qsTrId("specify-the-network-id")
                            validationError: addNetworkPopup.networkValidationError
                        }
                    }
                }
            }
            Column {
                spacing: Style.current.smallPadding
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding


                StatusSectionHeadline {
                    //% "Main networks"
                    text: qsTrId("main-networks")
                }


                NetworkRadioSelector {
                    network: Constants.networkMainnet
                }

                NetworkRadioSelector {
                    network: Constants.networkPOA
                }

                NetworkRadioSelector {
                    network: Constants.networkXDai
                }

                StatusSectionHeadline {
                    //% "Test networks"
                    text: qsTrId("test-networks")
                    anchors.leftMargin: -Style.current.padding
                    anchors.rightMargin: -Style.current.padding
                }

                NetworkRadioSelector {
                    network: Constants.networkGoerli
                }

                NetworkRadioSelector {
                    network: Constants.networkRinkeby
                }

                NetworkRadioSelector {
                    network: Constants.networkRopsten
                }

                StatusSectionHeadline {
                    //% "Custom Networks"
                    text: qsTrId("custom-networks")
                    anchors.leftMargin: -Style.current.padding
                    anchors.rightMargin: -Style.current.padding
                }

                Repeater {
                    model: profileModel.network.customNetworkList
                    delegate: NetworkRadioSelector {
                        networkName: name
                        network: customNetworkId
                    }
                }
            }
        }
    }

    StyledText {
        anchors.top: svNetworks.bottom
        anchors.topMargin: Style.current.padding
        //% "Under development\nNOTE: You will be logged out and all installed\nsticker packs will be removed and will\nneed to be reinstalled. Purchased sticker\npacks will not need to be re-purchased."
        text: qsTrId("under-development-nnote--you-will-be-logged-out-and-all-installed-nsticker-packs-will-be-removed-and-will-nneed-to-be-reinstalled--purchased-sticker-npacks-will-not-need-to-be-re-purchased-")
    }
}
