import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1 as StatusQControls

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.controls 1.0

Item {
    id: root

    property var ensUsernamesStore
    property var contactsStore
    property int profileContentWidth

    signal continueClicked(string output, string username)
    signal usernameUpdated(username: string);


    property string validationMessage: ""
    property bool valid: false
    property bool isStatus: true
    property bool loading: false
    property string ensStatus: ""

    property var validateENS: Backpressure.debounce(root, 500, function (ensName, isStatus){
        root.ensUsernamesStore.checkEnsUsernameAvailability(ensName, isStatus)
    });

    function validate(ensUsername) {
        validationMessage = "";
        valid = false;
        ensStatus = "";
        if (ensUsername.length < 4) {
            //% "At least 4 characters. Latin letters, numbers, and lowercase only."
            validationMessage = qsTrId("ens-username-hints");
        } else if(isStatus && !ensUsername.match(/^[a-z0-9]+$/)){
            //% "Letters and numbers only."
            validationMessage = qsTrId("ens-username-invalid");
        } else if(!isStatus && !ensUsername.endsWith(".eth")){
            //% "Type the entire username including the custom domain like username.domain.eth"
            validationMessage = qsTrId("ens-custom-username-hints")
        }
        return validationMessage === "";
    }

    function onKeyReleased(ensUsername){
        if (!validate(ensUsername)) {
            return;
        }
        loading = true;
        Qt.callLater(validateENS, ensUsername, isStatus)
    }

    Component {
        id: transactionDialogComponent
        StatusETHTransactionModal {
            ensUsernamesStore: root.ensUsernamesStore
            contactsStore: root.contactsStore
            onOpened: {
                root.ensUsernamesStore.fetchGasPrice()
            }
            title: qsTr("Connect username with your pubkey")
            onClosed: {
                destroy()
            }
            estimateGasFunction: function(selectedAccount) {
                if (ensUsername.text === "" || !selectedAccount) return 80000;
                return root.ensUsernamesStore.setPubKeyGasEstimate(ensUsername.text + (isStatus ? ".stateofus.eth" : "" ), selectedAccount.address)
            }
            onSendTransaction: function(selectedAddress, gasLimit, gasPrice, password) {
                return root.ensUsernamesStore.setPubKey(ensUsername.text + (isStatus ? ".stateofus.eth" : "" ),
                                                        selectedAddress,
                                                        gasLimit,
                                                        gasPrice,
                                                        "",
                                                        "",
                                                        password)
            }
            onSuccess: function(){
                usernameUpdated(ensUsername.text);
            }

            width: 475
            height: 500
        }
    }

    Item {
        id: ensContainer
        anchors.top: parent.top
        width: profileContentWidth
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            id: circleAt
            anchors.top: parent.top
            anchors.topMargin: Style.current.bigPadding*2
            anchors.horizontalCenter: parent.horizontalCenter
            width: 60
            height: 60
            radius: 120
            color: Theme.palette.primaryColor1

            SVGImage {
                id: imgIcon
                visible: ensStatus === Constants.ens_taken
                fillMode: Image.PreserveAspectFit
                source: Style.svg("block-icon-white")
                width: 20
                height: 20
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            StatusBaseText {
                visible: ensStatus !== Constants.ens_taken
                text: {
                    if((ensStatus === Constants.ens_available ||
                         ensStatus === Constants.ens_connected ||
                         ensStatus === Constants.ens_connected_dkey)) {
                        return "✓"
                    } else {
                        return "@"
                    }
                }
                opacity: 0.7
                font.weight: Font.Bold
                font.pixelSize: 18
                color: Theme.palette.indirectColor1
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Input {
            id: ensUsername
            placeholderText: !isStatus ? "vitalik94.domain.eth" : "vitalik94"
            anchors.top: circleAt.bottom
            anchors.topMargin: Style.current.bigPadding
            anchors.right: btnContinue.left
            anchors.rightMargin: Style.current.bigPadding
            Keys.onReleased: {
                onKeyReleased(ensUsername.text);
            }

            Connections {
                target: root.ensUsernamesStore.ensUsernamesModule
                onUsernameAvailabilityChecked: {
                    if(!validate(ensUsername.text)) return;
                    valid = false;
                    loading = false;
                    ensStatus = availabilityStatus;
                    switch(availabilityStatus){
                        case "available":
                        case "owned":
                        case "connected":
                        case "connected-different-key":
                            valid = true;
                            validationMessage = Constants.ensState[availabilityStatus]
                            break;
                        case "taken":
                            validationMessage = Constants.ensState[!isStatus ? 'taken-custom' : 'taken']
                            break;
                        case "already-connected":
                            validationMessage = Constants.ensState[availabilityStatus]
                            break;
                    }
                }
            }
        }

        StatusQControls.StatusRoundButton {
            id: btnContinue
            width: 40
            height: 40
            anchors.top: circleAt.bottom
            anchors.topMargin: Style.current.bigPadding
            anchors.right: parent.right
            type: StatusQControls.StatusRoundButton.Type.Secondary
            icon.name: "arrow-right"
            icon.width: 18
            icon.height: 14
            visible: valid
            onClicked: {
                if(!valid) return;

                if(ensStatus === Constants.ens_connected){
                    root.ensUsernamesStore.ensConnectOwnedUsername(ensUsername.text, isStatus);
                    continueClicked(ensStatus, ensUsername.text)
                    return;
                }

                if(ensStatus === Constants.ens_available){
                    continueClicked(ensStatus, ensUsername.text);
                    return;
                }

                if(ensStatus === Constants.ens_connected_dkey || ensStatus === Constants.ens_owned){
                    Global.openPopup(transactionDialogComponent, {ensUsername: ensUsername.text})
                    return;
                }
            }
        }

        Rectangle {
            id: ensTypeRect
            anchors.top: ensUsername.bottom
            anchors.topMargin: Style.current.bigPadding
            border.width: 1
            border.color: Style.current.border
            color: Style.current.background
            radius: 50
            height: 30
            width: 350

            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: Style.current.halfPadding
                anchors.leftMargin: Style.current.padding
                height: 20

                StatusBaseText {
                    text: !isStatus ?
                        //% "Custom domain"
                        qsTrId("ens-custom-domain")
                        :
                        ".stateofus.eth"
                    font.weight: Font.Bold
                    font.pixelSize: 12
                    anchors.leftMargin: Style.current.padding
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    text: !isStatus ?
                        //% "I want a stateofus.eth domain"
                        qsTrId("ens-want-domain")
                        :
                        //% "I own a name on another domain"
                        qsTrId("ens-want-custom-domain")
                    font.pixelSize: 12
                    color: Theme.palette.primaryColor1
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.padding

                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onClicked : {
                            isStatus = !isStatus;
                            let ensUser = ensUsername.text;
                            if(validate(ensUser))
                                validateENS(ensUser, isStatus)
                        }
                    }
                }
            }
        }

        StatusBaseText {
            id: validationResult
            text: validationMessage
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            anchors.top: ensTypeRect.bottom
            wrapMode: Text.WordWrap
            anchors.topMargin: Style.current.bigPadding
            color: Theme.palette.directColor1
        }
    }
}

