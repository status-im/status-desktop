import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import shared.controls 1.0
import shared.views.chat 1.0

StatusModal {
    id: root

    property var contactsStore
    property string publicKey

    signal verificationRefused(string senderPublicKey)
    signal responseSent(string senderPublicKey, string response)

    function updateVerificationDetails() {
        try {
            const request = root.contactsStore.getVerificationDetailsFromAsJson(root.publicKey)

            if (request.requestStatus === Constants.verificationStatus.canceled) {
                root.close()
            }

            d.senderPublicKey = request.from
            d.senderDisplayName = request.displayName
            d.senderIcon = request.icon
            d.challengeText = request.challenge
            d.responseText = request.response
            d.messageTimestamp = request.requestedAt
            d.responseTimestamp = request.repliedAt
        } catch (e) {
            console.error("Error getting or parsing verification data", e)
        }
    }

    Connections {
        target: root.contactsStore.receivedContactRequestsModel

        function onItemChanged(pubKey) {
            if (pubKey === root.publicKey)
                root.updateVerificationDetails()
        }
    }

    QtObject {
        id: d

        property string senderPublicKey: ""
        property string senderDisplayName: ""
        property string senderIcon: ""
        property string challengeText: ""
        property string responseText: ""
        property string messageTimestamp: ""
        property string responseTimestamp: ""
    }

    header.title: qsTr("%1 is asking you to verify your identity").arg(d.senderDisplayName)

    x: Math.round(((parent ? parent.width : 0) - width) / 2)
    y: Math.round(((parent ? parent.height : 0) - height) / 2)

    width: 480
    height: 230 + verificationMessage.height + verificationResponse.height

    onOpened: {
        root.updateVerificationDetails()
        verificationResponse.input.edit.forceActiveFocus(Qt.MouseFocusReason)
    }

    contentItem: Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding

        StatusBaseText {
            id: description
            width: parent.width
            color: Theme.palette.directColor1
            wrapMode: Text.WordWrap
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding
            text: qsTr("%1 would like to verify your identity. Answer the question to prove your identity to %2")
                    .arg(d.senderDisplayName).arg(d.senderDisplayName)
            font.pixelSize: 15
        }

        MessageView {
            id: verificationMessage
            anchors.top: description.bottom
            anchors.topMargin: Style.current.padding
            width: parent.width
            isMessage: true
            shouldRepeatHeader: true
            messageTimestamp: d.messageTimestamp
            senderId: d.senderPublicKey
            senderDisplayName: d.senderDisplayName
            senderIsEnsVerified: d.senderPublicKey !== "" && Utils.isEnsVerified(d.senderPublicKey)
            senderIcon: d.senderIcon
            messageText: d.challengeText
            messageContentType: Constants.messageContentType.messageType
            placeholderMessage: true
        }

        StatusInput {
            id: verificationResponse
            visible: !d.responseText
            anchors.top: verificationMessage.bottom
            anchors.topMargin: 5
            input.multiline: true
            placeholderText: qsTr("Provide answer to verification request from this contact.")
            minimumHeight: 152
            maximumHeight: 152
            width: parent.width
            input.verticalAlignment: TextEdit.AlignTop
            leftPadding: 0
            rightPadding: 0
            charLimit: 280
        }

        MessageView {
            id: responseMessage
            visible: !!d.responseText
            anchors.top: verificationMessage.bottom
            width: parent.width
            isMessage: true
            shouldRepeatHeader: true
            messageTimestamp: d.responseTimestamp
            senderId: userProfile.pubKey
            senderDisplayName: userProfile.displayName
            senderIsEnsVerified: !!userProfile.preferredName
            senderIcon: userProfile.icon
            messageText: d.responseText
            messageContentType: Constants.messageContentType.messageType
            placeholderMessage: true
        }

        StatusBaseText {
            id: responseSent
            visible: !!d.responseText
            width: parent.width
            color: Theme.palette.baseColor1
            wrapMode: Text.WordWrap
            anchors.top: responseMessage.bottom
            anchors.topMargin: 58
            text: qsTr("Your answer has been sent to %1.").arg(d.senderDisplayName)
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
        }
    }

    rightButtons: [
        StatusButton {
            visible: !d.responseText
            text: qsTr("Refuse Verification")
            onClicked: {
                root.verificationRefused(d.senderPublicKey)
                root.close();
            }
        },
        StatusButton {
            text: qsTr("Send Answer")
            visible: !d.responseText
            enabled: verificationResponse.text !== ""
            onClicked: {
                root.responseSent(d.senderPublicKey, Utils.escapeHtml(verificationResponse.text))
                d.responseText = verificationResponse.text
                d.responseTimestamp = Date.now()
            }
        },
        StatusFlatButton {
            visible: d.responseText
            text: qsTr("Change answer")
            onClicked: {
                d.responseText = ""
            }
        },
        StatusButton {
            visible: d.responseText
            text: qsTr("Close")
            onClicked: root.close()
        }
    ]
}
