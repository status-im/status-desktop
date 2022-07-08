import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import shared.controls 1.0
import shared.views.chat 1.0

StatusModal {
    id: root

    property string senderPublicKey: ""
    property string senderDisplayName: ""
    property string senderIcon: ""
    property string challengeText: ""
    property string responseText: ""
    property string messageTimestamp: ""
    property string responseTimestamp: ""

    signal verificationRefused(string senderPublicKey)
    signal responseSent(string senderPublicKey, string response)

    header.title: qsTr("%1 is asking you to verify your identity").arg(root.senderDisplayName)

    x: Math.round(((parent ? parent.width : 0) - width) / 2)
    y: Math.round(((parent ? parent.height : 0) - height) / 2)

    width: 480
    height: 230 + verificationMessage.height + verificationResponse.height

    onOpened: {
        verificationResponse.input.edit.forceActiveFocus(Qt.MouseFocusReason)
    }
    onClosed: {
        root.destroy();
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
                    .arg(root.senderDisplayName).arg(root.senderDisplayName)
            font.pixelSize: 15
        }

        MessageView {
            id: verificationMessage
            anchors.top: description.bottom
            anchors.topMargin: Style.current.padding
            isMessage: true
            shouldRepeatHeader: true
            messageTimestamp: root.messageTimestamp
            senderDisplayName: root.senderDisplayName
            senderIcon: root.senderIcon
            message: root.challengeText
            messageContentType: Constants.messageContentType.messageType
            placeholderMessage: true
        }

        StatusInput {
            id: verificationResponse
            visible: !responseText
            anchors.top: verificationMessage.bottom
            anchors.topMargin: 5
            input.multiline: true
            input.placeholderText: qsTr("Provide answer to verification request from this contact.")
            input.implicitHeight: 152
            width: parent.width
            input.verticalAlignment: TextEdit.AlignTop
            leftPadding: 0
            rightPadding: 0
            charLimit: 280
        }

        MessageView {
            id: responseMessage
            visible: !!root.responseText
            anchors.top: verificationMessage.bottom
            isMessage: true
            shouldRepeatHeader: true
            messageTimestamp: root.responseTimestamp
            senderDisplayName: userProfile.name
            senderIcon: userProfile.icon
            message: root.responseText
            messageContentType: Constants.messageContentType.messageType
            placeholderMessage: true
        }

        StatusBaseText {
            id: responseSent
            visible: !!root.responseText
            width: parent.width
            color: Theme.palette.baseColor1
            wrapMode: Text.WordWrap
            anchors.top: responseMessage.bottom
            anchors.topMargin: 58
            text: qsTr("You're answer has been sent to %1.").arg(root.senderDisplayName)
            font.pixelSize: 13
            horizontalAlignment:  Text.AlignHCenter
        }
    }

    rightButtons: [
        StatusButton {
            visible: !root.responseText
            text: qsTr("Refuse Verification")
            onClicked: {
                root.verificationRefused(root.senderPublicKey)
                root.close();
            }
        },
        StatusButton {
            text: qsTr("Send Answer")
            visible: !root.responseText
            enabled: verificationResponse.text !== ""
            onClicked: {
                root.responseSent(root.senderPublicKey, Utils.escapeHtml(verificationResponse.text))
                root.responseText = verificationResponse.text
                root.responseTimestamp = Date.now()
            }
        },
        StatusFlatButton {
            visible: root.responseText
            text: qsTr("Change answer")
            onClicked: {
                root.responseText = ""
            }
        },
        StatusButton {
            visible: root.responseText
            text: qsTr("Close")
            onClicked: root.close()
        }
    ]
}
