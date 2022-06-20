import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import shared 1.0
import shared.views 1.0
import shared.panels 1.0
import shared.popups 1.0
import "../stores"

StatusModal {
    property var request
    property var selectedAccount

    readonly property int bytes32Length: 66

    property bool interactedWith: false
    property bool showSigningPhrase: false

    property alias transactionSigner: transactionSigner

    property var signMessage: function(enteredPassword) {}

    property var web3Response


    anchors.centerIn: parent
    id: root

    //% "Signature request"
    header.title: qsTrId("signature-request")
    height: Style.dp(504)

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
            return RootStore.getHex2Ascii(input)
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

    contentItem: Item {
        width: root.width

        TransactionSigner {
            id: transactionSigner
            width: parent.width
            signingPhrase: WalletStore.signingPhrase
            visible: showSigningPhrase
        }

        Column {
            id: content
            visible: !showSigningPhrase
            width: root.width - Style.current.padding * 2
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding

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
                            font.pixelSize: Style.current.primaryTextFontSize
                            height: Style.dp(22)
                            text: selectedAccount.name
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                        }
                        SVGImage {
                            id: imgFromWallet
                            sourceSize.height: Style.dp(18)
                            sourceSize.width: Style.dp(18)
                            visible: true
                            horizontalAlignment: Image.AlignLeft
                            width: undefined
                            anchors.verticalCenter: parent.verticalCenter
                            fillMode: Image.PreserveAspectFit
                            source: Style.svg("walletIcon")
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

                    // TODO; replace with StatusModal
                    ModalPopup {
                        id: messagePopup
                        //% "Message"
                        title: qsTrId("message")
                        height: Style.dp(286)
                        width: Style.dp(400)
                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: Style.current.padding
                            anchors.rightMargin: Style.current.padding
                            ScrollView {
                                width: parent.width
                                height: Style.dp(150)
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
                            width: Style.dp(250)
                            height: Style.dp(22)
                            font.pixelSize: Style.current.primaryTextFontSize
                            text: messageToSign()
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            color: Style.current.secondaryText
                        }
                        SVGImage {
                            width: Style.dp(13)
                            anchors.verticalCenter: parent.verticalCenter
                            fillMode: Image.PreserveAspectFit
                            source: Style.svg("caret")
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

    }

    leftButtons: [
        StatusFlatButton {
            id: btnReject
            //% "Reject"
            text: qsTrId("reject")
            type: StatusBaseButton.Type.Danger
            onClicked: close()
        }
    ]

    rightButtons: [
        StatusButton {
            id: btnNext
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
    ]
}


