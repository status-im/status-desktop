import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1 as StatusQControls
import StatusQ.Components 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.controls 1.0
import shared.popups.send 1.0

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
            validationMessage = qsTr("At least 4 characters. Latin letters, numbers, and lowercase only.");
        } else if(isStatus && !ensUsername.match(/^[a-z0-9]+$/)){
            validationMessage = qsTr("Letters and numbers only.");
        } else if(!isStatus && !ensUsername.endsWith(".eth")){
            validationMessage = qsTr("Type the entire username including the custom domain like username.domain.eth")
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
        SendModal {
            id: connectEnsModal
            modalHeader: qsTr("Connect username with your pubkey")
            interactive: false
            preSelectedSendType: Constants.SendType.ENSSetPubKey
            preSelectedRecipient: root.ensUsernamesStore.getEnsRegisteredAddress()
            preDefinedAmountToSend: LocaleUtils.numberToLocaleString(0)
            preSelectedHoldingID: Constants.ethToken
            preSelectedHoldingType: Constants.TokenType.ERC20
            sendTransaction: function() {
                if(bestRoutes.count === 1) {
                    let path = bestRoutes.firstItem()
                    let eip1559Enabled = path.gasFees.eip1559Enabled
                    root.ensUsernamesStore.authenticateAndSetPubKey(
                                root.ensUsernamesStore.chainId,
                                ensUsername.text + (isStatus ? ".stateofus.eth" : "" ),
                                store.selectedSenderAccount.address,
                                path.gasAmount,
                                eip1559Enabled ? "" : path.gasFees.gasPrice,
                                "",
                                "",
                                eip1559Enabled,
                                )
                }
            }
            Connections {
                target: root.ensUsernamesStore.ensUsernamesModule
                function onTransactionWasSent(chainId: int, txHash: string, error: string) {
                    if (!!error) {
                        if (error.includes(Constants.walletSection.cancelledMessage)) {
                            return
                        }
                        connectEnsModal.sendingError.text = error
                        return connectEnsModal.sendingError.open()
                    }
                    usernameUpdated(ensUsername.text);
                    let url =  "%1/%2".arg(connectEnsModal.store.getEtherscanLink(chainId)).arg(txHash)
                    Global.displayToastMessage(qsTr("Transaction pending..."),
                                               qsTr("View on etherscan"),
                                               "",
                                               true,
                                               Constants.ephemeralNotificationType.normal,
                                               url)
                    connectEnsModal.close()
                }
            }
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
            textField.objectName: "ensUsernameInput"
            placeholderText: !isStatus ? "vitalik94.domain.eth" : "vitalik94"
            anchors.left: parent.left
            anchors.top: circleAt.bottom
            anchors.topMargin: Style.current.bigPadding
            anchors.right: btnContinue.left
            anchors.rightMargin: Style.current.bigPadding
            Keys.onReleased: {
                onKeyReleased(ensUsername.text);
            }

            Connections {
                target: root.ensUsernamesStore.ensUsernamesModule
                function onUsernameAvailabilityChecked(availabilityStatus: string) {
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
            objectName: "ensNextButton"
            icon.name: "arrow-right"
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
                        qsTr("Custom domain")
                        :
                        ".stateofus.eth"
                    font.weight: Font.Bold
                    font.pixelSize: 12
                    anchors.leftMargin: Style.current.padding
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    text: !isStatus ?
                        qsTr("I want a stateofus.eth domain")
                        :
                        qsTr("I own a name on another domain")
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

