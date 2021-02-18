import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.13
import "../../../imports"
import "../../../shared"
import "../../../shared/status"

ModalPopup {
    property var request
    property var selectedAccount

    readonly property int bytes32Length: 66

    property bool interactedWith: false
    property bool showSigningPhrase: false

    property alias transactionSigner: transactionSigner

    property var signMessage: function(enteredPassword) {}
    
    property var web3Response


    id: root

    //% "Signature request"
    title: qsTrId("signature-request")
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
            return utilsModel.hex2Ascii(input)
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

    TransactionSigner {
        id: transactionSigner
        width: parent.width
        signingPhrase: walletModel.signingPhrase
        visible: showSigningPhrase
    }

    Column {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        visible: !showSigningPhrase

        LabelValueRow {
            //% "From"
            label: qsTrId("from")
            value: Item {
                id: itmFromValue
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter
                Row {
                    spacing: Style.current.halfPadding
                    rightPadding: 0
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    StyledText {
                        font.pixelSize: 15
                        height: 22
                        text: selectedAccount.name
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    SVGImage {
                        id: imgFromWallet
                        sourceSize.height: 18
                        sourceSize.width: 18
                        visible: true
                        horizontalAlignment: Image.AlignLeft
                        width: undefined
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                        source: "../../img/walletIcon.svg"
                        ColorOverlay {
                            visible: parent.visible
                            anchors.fill: parent
                            source: parent
                            color: selectedAccount.iconColor
                        }
                    }
                }
            }
        }

        LabelValueRow {
            //% "Data"
            label: qsTrId("data")
            value: Item {
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter

                ModalPopup {
                    id: messagePopup
                    //% "Message"
                    title: qsTrId("message")
                    height: 286
                    width: 400
                    Item {
                        anchors.fill: parent
                        anchors.leftMargin: Style.current.padding
                        anchors.rightMargin: Style.current.padding
                        ScrollView {
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
                    spacing: Style.current.halfPadding
                    rightPadding: 0
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    StyledText {
                        width: 250
                        font.pixelSize: 15
                        height: 22
                        text: messageToSign()
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        color: Style.current.secondaryText
                    }
                    SVGImage {
                        width: 13
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                        source: "../../img/caret.svg"
                        rotation: 270
                        ColorOverlay {
                            anchors.fill: parent
                            source: parent
                            color: Style.current.secondaryText
                        }
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


    footer: Item {
        width: parent.width
        height: btnReject.height

        StatusButton {
            id: btnReject
            anchors.right:btnNext.left
            anchors.rightMargin: Style.current.padding
            //% "Reject"
            text: qsTrId("reject")
            color: Style.current.danger
            type: "secondary"
            onClicked: close()
        }

        StatusButton {
            id: btnNext
            anchors.right: parent.right
            text: showSigningPhrase ? 
                    //% "Sign"
                    qsTrId("transactions-sign") : 
                    //% "Sign with password"
                    qsTrId("sign-with-password")
            onClicked: {
                if(!showSigningPhrase){
                    showSigningPhrase = true;
                    transactionSigner.forceActiveFocus(Qt.MouseFocusReason)
                } else {
                    root.signMessage(transactionSigner.enteredPassword)
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

