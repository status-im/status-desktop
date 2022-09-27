import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

import shared.views.chat 1.0

StatusDialog {
    id: root

    /* required*/ property string userPublicKey
    property int verificationStatus
    property string verificationChallenge
    property string verificationResponse
    property string verificationResponseDisplayName
    property string verificationResponseIcon
    property string verificationRequestedAt
    property string verificationRepliedAt

    signal verificationRequestCanceled(string userPublicKey)
    signal untrustworthyVerified(string userPublicKey)
    signal trustedVerified(string userPublicKey)

    title: qsTr("Verify %1's Identity").arg(root.verificationResponseDisplayName)

    footer: StatusDialogFooter {
        leftButtons: ObjectModel {
            StatusButton {
                text: qsTr("Cancel verification")
                type: StatusBaseButton.Type.Danger
                visible: root.verificationStatus !== Constants.verificationStatus.verified
                onClicked: {
                    root.verificationRequestCanceled(root.userPublicKey)
                    root.close()
                }
            }
        }

        rightButtons: ObjectModel {
            StatusButton {
                text: qsTr("Mark Untrustworthy")
                enabled: root.verificationResponse !== ""
                type: StatusBaseButton.Type.Danger
                onClicked: {
                    root.untrustworthyVerified(root.userPublicKey)
                    root.close()
                }
            }
            StatusButton {
                text: qsTr("Confirm Identity")
                enabled: root.verificationResponse !== ""
                type: StatusBaseButton.Type.Primary
                onClicked: {
                    root.trustedVerified(root.userPublicKey)
                    root.close()
                }
            }
        }
    }

    contentItem: ColumnLayout {
        MessageView {
            id: challengeMessage
            Layout.fillWidth: true
            isMessage: true
            shouldRepeatHeader: true
            messageTimestamp: root.verificationRequestedAt
            senderId: userProfile.pubKey
            senderDisplayName: userProfile.name
            senderIcon: userProfile.icon
            senderIsEnsVerified: !!userProfile.ensName
            messageText: root.verificationChallenge
            messageContentType: Constants.messageContentType.messageType
            placeholderMessage: true
        }
        MessageView {
            id: responseMessage
            visible: root.verificationResponse !== ""
            Layout.fillWidth: true
            isMessage: true
            shouldRepeatHeader: true
            messageTimestamp: root.verificationRepliedAt
            senderId: root.userPublicKey
            senderDisplayName: root.verificationResponseDisplayName
            senderIcon: root.verificationResponseIcon
            senderIsEnsVerified: Utils.isEnsVerified(root.userPublicKey)
            messageText: root.verificationResponse
            messageContentType: Constants.messageContentType.messageType
            placeholderMessage: true
        }
        StatusBaseText {
            id: waitingForText
            visible: !root.verificationResponse
            text: qsTr("Waiting for %1's response...").arg(root.verificationResponseDisplayName)
            font.pixelSize: Style.current.additionalTextSize
            horizontalAlignment : Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: Theme.palette.baseColor1
        }
    }
}
