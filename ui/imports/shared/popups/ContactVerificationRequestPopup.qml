import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

import shared.controls 1.0
import shared.views.chat 1.0

import utils 1.0

StatusDialog {
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
        property double messageTimestamp
        property double responseTimestamp
    }

    title: qsTr("%1 is asking you to verify your identity").arg(d.senderDisplayName)
    padding: 0

    onAboutToShow: {
        root.updateVerificationDetails()
        verificationResponse.input.edit.forceActiveFocus(Qt.MouseFocusReason)
    }

    StatusScrollView {
        id: scrollView
        anchors.fill: parent

        contentWidth: availableWidth
        implicitWidth: 560

        ColumnLayout {
            width: scrollView.availableWidth
            spacing: Style.current.padding

            StatusBaseText {
                id: description
                color: Theme.palette.directColor1
                wrapMode: Text.WordWrap
                text: qsTr("%1 would like to verify your identity. Answer the question to prove your identity to %2")
                        .arg(d.senderDisplayName).arg(d.senderDisplayName)
                font.pixelSize: 15
                Layout.fillWidth: true
            }

            SimplifiedMessageView {
                id: verificationMessage
                timestamp: d.messageTimestamp
                messageDetails.messageText: d.challengeText
                messageDetails.sender.displayName: d.senderDisplayName
                messageDetails.sender.profileImage.name: d.senderIcon
                messageDetails.sender.profileImage.assetSettings.isImage: true
                messageDetails.sender.profileImage.pubkey: d.senderPublicKey
                messageDetails.sender.profileImage.colorId: Utils.colorIdForPubkey(d.senderPublicKey)
                messageDetails.sender.profileImage.colorHash: Utils.getColorHashAsJson(d.senderPublicKey, Utils.isEnsVerified(d.senderPublicKey))
                Layout.fillWidth: true
            }

            StatusInput {
                id: verificationResponse
                visible: !d.responseText
                input.multiline: true
                placeholderText: qsTr("Provide answer to verification request from this contact.")
                minimumHeight: 152
                maximumHeight: 152
                input.verticalAlignment: TextEdit.AlignTop
                charLimit: 280
                Layout.fillWidth: true
            }

            SimplifiedMessageView {
                id: responseMessage
                visible: !!d.responseText
                timestamp: d.responseTimestamp
                messageDetails.messageText: d.responseText
                messageDetails.sender.displayName: userProfile.displayName
                messageDetails.sender.profileImage.name: userProfile.icon
                messageDetails.sender.profileImage.assetSettings.isImage: true
                messageDetails.sender.profileImage.pubkey: userProfile.pubKey
                messageDetails.sender.profileImage.colorId: Utils.colorIdForPubkey(userProfile.pubKey)
                messageDetails.sender.profileImage.colorHash: Utils.getColorHashAsJson(userProfile.pubKey, !!userProfile.preferredName)
                Layout.fillWidth: true
            }

            StatusBaseText {
                id: responseSent
                visible: !!d.responseText
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                text: qsTr("Your answer has been sent to %1.").arg(d.senderDisplayName)
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
        }
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                visible: !d.responseText
                text: qsTr("Refuse Verification")
                onClicked: {
                    root.verificationRefused(d.senderPublicKey)
                    root.close();
                }
            }
            StatusButton {
                text: qsTr("Send Answer")
                visible: !d.responseText
                enabled: verificationResponse.text !== ""
                onClicked: {
                    root.responseSent(d.senderPublicKey, Utils.escapeHtml(verificationResponse.text))
                    d.responseText = verificationResponse.text
                    d.responseTimestamp = Date.now()
                }
            }
            StatusFlatButton {
                visible: d.responseText
                text: qsTr("Change answer")
                onClicked: {
                    d.responseText = ""
                }
            }
            StatusButton {
                visible: d.responseText
                text: qsTr("Close")
                onClicked: root.close()
            }
        }
    }
}
