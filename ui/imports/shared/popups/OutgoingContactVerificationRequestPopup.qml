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
    padding: 0

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

    StatusScrollView {
        id: scrollView
        anchors.fill: parent

        contentWidth: availableWidth
        implicitWidth: 560

        ColumnLayout {
            width: scrollView.availableWidth
            spacing: Style.current.padding

            SimplifiedMessageView {
                id: challengeMessage
                timestamp: root.verificationRequestedAt
                messageDetails.messageText: root.verificationChallenge
                messageDetails.sender.displayName: userProfile.name
                messageDetails.sender.profileImage.name: userProfile.icon
                messageDetails.sender.profileImage.assetSettings.isImage: true
                messageDetails.sender.profileImage.pubkey: userProfile.pubKey
                messageDetails.sender.profileImage.colorId: Utils.colorIdForPubkey(userProfile.pubKey)
                messageDetails.sender.profileImage.colorHash: Utils.getColorHashAsJson(userProfile.pubKey, !!userProfile.preferredName)
                Layout.fillWidth: true
            }

            SimplifiedMessageView {
                id: responseMessage
                visible: root.verificationResponse !== ""
                timestamp: root.verificationRepliedAt
                messageDetails.messageText: root.verificationResponse
                messageDetails.sender.displayName: root.verificationResponseDisplayName
                messageDetails.sender.profileImage.name: root.verificationResponseIcon
                messageDetails.sender.profileImage.assetSettings.isImage: true
                messageDetails.sender.profileImage.pubkey: root.userPublicKey
                messageDetails.sender.profileImage.colorId: Utils.colorIdForPubkey(root.userPublicKey)
                messageDetails.sender.profileImage.colorHash: Utils.getColorHashAsJson(root.userPublicKey, Utils.isEnsVerified(root.userPublicKey))
                Layout.fillWidth: true
            }

            StatusBaseText {
                id: waitingForText
                visible: !responseMessage.visible
                text: qsTr("Waiting for %1's response...").arg(root.verificationResponseDisplayName)
                font.pixelSize: Style.current.additionalTextSize
                horizontalAlignment : Text.AlignHCenter
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                color: Theme.palette.baseColor1
            }
        }
    }
}
