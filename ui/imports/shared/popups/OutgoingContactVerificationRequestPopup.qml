import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared.views.chat 1.0

CommonContactDialog {
    id: root

    property int verificationStatus
    property string verificationChallenge
    property string verificationResponse
    property string verificationResponseDisplayName
    property string verificationResponseIcon
    property string verificationRequestedAt
    property string verificationRepliedAt

    readonly property bool hasReply: root.verificationResponse !== ""

    signal verificationRequestCanceled(string publicKey)
    signal untrustworthyVerified(string publicKey)
    signal trustedVerified(string publicKey)

    title: !hasReply ? qsTr("ID verification pending") : qsTr("Review ID verification reply")

    rightButtons: ObjectModel {
        StatusFlatButton {
            text: qsTr("Cancel request")
            type: StatusBaseButton.Type.Danger
            borderColor: "transparent"
            visible: !root.hasReply
            onClicked: {
                root.verificationRequestCanceled(root.publicKey)
                root.close()
            }
        }
        StatusButton {
            text: qsTr("Done")
            visible: !root.hasReply
            onClicked: root.close()
        }

        StatusButton {
            text: qsTr("Mark as untrusted")
            visible: root.hasReply
            type: StatusBaseButton.Type.Danger
            onClicked: {
                root.untrustworthyVerified(root.publicKey)
                root.close()
            }
        }
        StatusButton {
            text: qsTr("Mark as verified")
            visible: root.hasReply
            type: StatusBaseButton.Type.Success
            onClicked: {
                root.trustedVerified(root.publicKey)
                root.close()
            }
        }
    }

    SimplifiedMessageView {
        id: challengeMessage
        timestamp: root.verificationRequestedAt
        messageDetails.messageText: root.verificationChallenge
        messageDetails.sender.id: Global.userProfile.pubKey
        messageDetails.sender.displayName: Global.userProfile.name
        messageDetails.sender.profileImage.name: Global.userProfile.icon
        messageDetails.sender.profileImage.assetSettings.isImage: true
        messageDetails.sender.profileImage.colorId: Utils.colorIdForPubkey(Global.userProfile.pubKey)
        messageDetails.sender.profileImage.colorHash: Utils.getColorHashAsJson(Global.userProfile.pubKey, !!Global.userProfile.preferredName)
        messageDetails.sender.isEnsVerified: !!Global.userProfile.preferredName
        Layout.fillWidth: true
    }

    SimplifiedMessageView {
        id: responseMessage
        visible: root.hasReply
        timestamp: root.verificationRepliedAt
        messageDetails.messageText: root.verificationResponse
        messageDetails.sender.id: root.publicKey
        messageDetails.sender.displayName: root.verificationResponseDisplayName
        messageDetails.sender.profileImage.name: root.verificationResponseIcon
        messageDetails.sender.profileImage.assetSettings.isImage: true
        messageDetails.sender.profileImage.colorId: Utils.colorIdForPubkey(root.publicKey)
        messageDetails.sender.profileImage.colorHash: Utils.getColorHashAsJson(root.publicKey)
        messageDetails.sender.isEnsVerified: contactDetails.ensVerified
        Layout.fillWidth: true
    }

    StatusBaseText {
        Layout.fillWidth: true
        Layout.topMargin: Style.current.halfPadding
        text: root.hasReply ? qsTr("Still not sure?") +  " " + Utils.getLinkStyle(qsTr("Ask something else"), hoveredLink, Style.current.blue)
                            : qsTr("Awaiting %1's response...").arg(root.verificationResponseDisplayName)
        font.pixelSize: Style.current.additionalTextSize
        horizontalAlignment : Text.AlignHCenter
        wrapMode: Text.WordWrap
        textFormat: Text.RichText
        color: root.hasReply ? Theme.palette.directColor1 : Theme.palette.baseColor1
        onLinkActivated: {
            root.verificationRequestCanceled(root.publicKey)
            root.close()
            Global.openSendIDRequestPopup(root.publicKey, root.contactDetails, null)
        }
    }
}
