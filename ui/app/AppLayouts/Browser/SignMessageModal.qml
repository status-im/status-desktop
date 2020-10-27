import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import "../../../imports"
import "../../../shared"
import "../../../shared/status"

ModalPopup {
    property var request

    readonly property int bytes32Length: 66

    property bool interactedWith: false

    property alias transactionSigner: transactionSigner

    property var signMessage: function(enteredPassword) {}
    
    property var web3Response

    id: root

    title: qsTr("Signing a message")
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

    function displayValue(input){
        if(Utils.isHex(input) && Utils.startsWith0x(input)){
            if (input.length === bytes32Length){
                return input;
            }
            return utilsModel.hex2Ascii(input)
        }
        return input;  
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding

        ScrollView {
            id: messageToSign
            width: parent.width
            height: 100
            TextArea {
                wrapMode: TextEdit.Wrap
                readOnly: true
                text: {
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
            }
        }

        TransactionSigner {
            id: transactionSigner
            width: parent.width
            anchors.top: messageToSign.bottom
            anchors.topMargin: Style.current.padding * 3
            signingPhrase: walletModel.signingPhrase
            reset: function() {
                signingPhrase = Qt.binding(function() { return walletModel.signingPhrase })
            }
        }
    }


    footer: Item {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        StatusButton {
            id: btnNext
            anchors.right: parent.right
            text: qsTr("Sign")
            onClicked: root.signMessage(transactionSigner.enteredPassword)
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

