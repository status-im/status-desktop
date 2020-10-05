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

    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        //% "Error sending the transaction"
        title: qsTrId("error-sending-the-transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

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
        stack.reset()
    }

    TransactionStackView {
        id: stack
        anchors.fill: parent
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
        onGroupActivated: {
            root.title = group.headerText
            btnNext.text = group.footerText
        }
        TransactionFormGroup {
            id: group3
            headerText: qsTr("Signing a message")
            footerText: qsTr("Sign")

            ScrollView {
                id: messageToSign
                width: stack.width
                height: 100
                TextArea {
                    wrapMode: TextEdit.Wrap
                    readOnly: true
                    text: {
                        switch(request.payload.method){
                            case "personal_sign":
                                return request.payload.params[0].length === bytes32Length ? request.payload.params[0] : utilsModel.hex2Ascii(request.payload.params[0]);
                            case "eth_sign":
                                return request.payload.params[1];
                            case "eth_signTypedData":
                            case "eth_signTypedData_v3":
                                return JSON.stringify(request.payload.params[1]); // TODO: requires design
                            default: 
                                return JSON.stringify(request.payload.params); // support for any unhandled sign method 
                        }
                    }
                }
            }

            TransactionSigner {
                id: transactionSigner
                width: stack.width
                anchors.top: messageToSign.bottom
                anchors.topMargin: Style.current.padding * 3
                signingPhrase: walletModel.signingPhrase
                reset: function() {
                    signingPhrase = Qt.binding(function() { return walletModel.signingPhrase })
                }
            }
        }
    }

    footer: Item {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        StyledButton {
            id: btnBack
            anchors.left: parent.left
            width: 44
            height: 44
            visible: !stack.isFirstGroup
            label: ""
            background: Rectangle {
                anchors.fill: parent
                border.width: 0
                radius: width / 2
                color: btnBack.hovered ? Qt.darker(btnBack.btnColor, 1.1) : btnBack.btnColor

                SVGImage {
                    width: 20.42
                    height: 15.75
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                    source: "../../img/arrow-right.svg"
                    rotation: 180
                }
            }
            onClicked: {
                stack.back()
            }
        }
        StatusButton {
            id: btnNext
            anchors.right: parent.right
            //% "Next"
            text: qsTrId("next")
            enabled: stack.currentGroup.isValid && !stack.currentGroup.isPending
            onClicked: {
                const validity = stack.currentGroup.validate()
                if (validity.isValid && !validity.isPending) {
                    if (stack.isLastGroup) {
                        return root.signMessage(transactionSigner.enteredPassword);
                    }
                    stack.next()
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

