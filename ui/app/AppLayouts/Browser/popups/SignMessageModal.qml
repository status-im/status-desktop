import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Popups

import utils
import shared
import shared.views
import shared.panels
import shared.popups

import AppLayouts.stores.Browser as BrowserStores

StatusModal {
    id: root

    required property BrowserStores.BrowserRootStore browserRootStore
    required property string signingPhrase

    property var request
    property var selectedAccount

    readonly property int bytes32Length: 66

    property bool interactedWith: false
    property bool showSigningPhrase: false

    property alias transactionSigner: transactionSigner

    property var signMessage: function(enteredPassword) {}

    property var web3Response

    anchors.centerIn: parent

    title: qsTr("Signature request")
    height: 504

    onClosed: {
        if(!interactedWith){
            web3Response(JSON.stringify({
                "type": "web3-send-async-callback",
                "messageId": request.messageId,
                "error": {
                    "code": 4100
                }
            }));
        }
    }

    onOpened: {
        showSigningPhrase = false;
    }

    function displayValue(input){
        if(Utils.isHex(input) && Utils.startsWith0x(input)){
            if (input.length === bytes32Length){
                return input;
            }
            return root.browserRootStore.getHex2Ascii(input)
        }
        return input;
    }

    function messageToSign(){
        switch(request.payload.method){
            case Constants.personal_sign:
                return displayValue(request.payload.params[0]);
            case Constants.eth_sign:
                return displayValue(request.payload.params[1]);
            case Constants.eth_signTypedData:
            case Constants.eth_signTypedData_v3:
                return JSON.stringify(request.payload.params[1]); // TODO: requires design
            default:
                return JSON.stringify(request.payload.params); // support for any unhandled sign method
        }
    }

    component LabelValueRow: Item {
        property alias label: txtLabel.text
        property alias value: itmValue.children
        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
        Layout.preferredWidth: parent.width
        width: parent.width
        height: 52

        StatusBaseText {
            id: txtLabel
            height: parent.height
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            width: 105
        }
        Item {
            id: itmValue
            anchors.left: txtLabel.right
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
        }
    }

    contentItem: Item {
        width: root.width

        TransactionSigner {
            id: transactionSigner
            width: parent.width
            signingPhrase: root.signingPhrase // FIXME
            visible: showSigningPhrase
        }

        Column {
            id: content
            visible: !showSigningPhrase
            width: root.width - Theme.padding * 2
            anchors.left: parent.left
            anchors.leftMargin: Theme.padding

            LabelValueRow {
                label: qsTr("From")
                value: Item {
                    anchors.fill: parent
                    anchors.verticalCenter: parent.verticalCenter
                    Row {
                        spacing: Theme.halfPadding
                        rightPadding: 0
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        StatusBaseText {
                            height: 22
                            text: selectedAccount.name
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                        }
                        StatusIcon {
                            id: imgFromWallet
                            height: 18
                            width: 18
                            visible: true
                            horizontalAlignment: Image.AlignLeft
                            anchors.verticalCenter: parent.verticalCenter
                            icon: "walletIcon"
                            color: selectedAccount.iconColor
                        }
                    }
                }
            }

            LabelValueRow {
                label: qsTr("Data")
                value: Item {
                    anchors.fill: parent
                    anchors.verticalCenter: parent.verticalCenter

                    // TODO; replace with StatusModal
                    ModalPopup {
                        id: messagePopup
                        title: qsTr("Message")
                        height: 286
                        width: 400
                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.padding
                            anchors.rightMargin: Theme.padding
                            StatusScrollView {
                                width: parent.width
                                height: 150
                                TextArea {
                                    wrapMode: TextEdit.Wrap
                                    readOnly: true
                                    text: messageToSign()
                                }
                            }
                        }
                    }

                    Row {
                        spacing: Theme.halfPadding
                        rightPadding: 0
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        StatusBaseText {
                            width: 250
                            height: 22
                            text: messageToSign()
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            color: Theme.palette.secondaryText
                        }
                        StatusIcon {
                            width: 13
                            anchors.verticalCenter: parent.verticalCenter
                            icon: "caret"
                            rotation: 270
                            color: Theme.palette.secondaryText
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        visible: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: messagePopup.open()
                    }
                }
            }
        }

    }

    leftButtons: [
        StatusFlatButton {
            id: btnReject
            text: qsTr("Reject")
            type: StatusBaseButton.Type.Danger
            onClicked: close()
        }
    ]

    rightButtons: [
        StatusButton {
            id: btnNext
            text: showSigningPhrase ?
                    qsTr("Sign") :
                    qsTr("Sign with password")
            onClicked: {
                if(!showSigningPhrase){
                    showSigningPhrase = true;
                    transactionSigner.forceActiveFocus(Qt.MouseFocusReason)
                } else {
                    root.signMessage(transactionSigner.enteredPassword)
                }
            }
        }
    ]
}


