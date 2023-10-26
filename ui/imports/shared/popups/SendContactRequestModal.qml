import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import utils 1.0
import shared.controls.chat 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: root

    property var rootStore

    required property string userPublicKey
    required property var contactDetails

    property string challengeText: qsTr("Say who you are / why you want to become a contact...")
    property string buttonText: qsTr("Send Contact Request")

    signal accepted(string message)

    width: 480
    horizontalPadding: Style.current.padding
    verticalPadding: Style.current.bigPadding

    title: qsTr("Send Contact Request to %1").arg(d.mainDisplayName)

    onAboutToShow: {
        messageInput.input.edit.forceActiveFocus()

        // (request) update from mailserver
        if (d.userDisplayName === "") {
            root.rootStore.contactStore.requestContactInfo(root.userPublicKey)
            d.loadingContactDetails = true
        }
    }

    QtObject {
        id: d

        readonly property int maxMsgLength: 280
        readonly property int minMsgLength: 1
        readonly property int msgHeight: 152
        readonly property int contentSpacing: Style.current.halfPadding

        property bool loadingContactDetails: false

        property var contactDetails: root.contactDetails

        readonly property bool userIsEnsVerified: contactDetails.ensVerified
        readonly property string userDisplayName: contactDetails.displayName
        readonly property string userNickName: contactDetails.localNickname
        readonly property string prettyEnsName: contactDetails.name
        readonly property string aliasName: contactDetails.alias
        readonly property string mainDisplayName: ProfileUtils.displayName(userNickName, prettyEnsName, userDisplayName, aliasName)
        readonly property var userIcon: contactDetails.largeImage
    }

    Connections {
        target: root.rootStore.contactStore.contactsModule

        function onContactInfoRequestFinished(publicKey, ok) {
            if (publicKey !== root.userPublicKey)
                return
            if (ok)
                d.contactDetails = Utils.getContactDetailsAsJson(root.userPublicKey, false)
            d.loadingContactDetails = false
        }
    }

    contentItem: ColumnLayout {
        spacing: d.contentSpacing

        ProfileHeader {
            Layout.fillWidth: true
            displayName: d.mainDisplayName
            pubkey: root.userPublicKey
            icon: d.userIcon
            userIsEnsVerified: d.userIsEnsVerified
            isContact: d.contactDetails.isContact
            trustStatus: d.contactDetails.trustStatus
            imageSize: ProfileHeader.ImageSize.Middle
            loading: d.loadingContactDetails
        }

        StatusInput {
            id: messageInput
            input.edit.objectName: "ProfileSendContactRequestModal_sayWhoYouAreInput"
            Layout.fillWidth: true
            charLimit: d.maxMsgLength
            placeholderText: root.challengeText
            input.multiline: true
            minimumHeight: d.msgHeight
            maximumHeight: d.msgHeight
            input.verticalAlignment: TextEdit.AlignTop
            validators: StatusMinLengthValidator {
                minLength: d.minMsgLength
                errorMessage: Utils.getErrorMessage(messageInput.errors, qsTr("who are you"))
            }
        }
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                objectName: "ProfileSendContactRequestModal_sendContactRequestButton"
                enabled: messageInput.valid
                text: root.buttonText
                onClicked: {
                    root.accepted(messageInput.text);
                    root.close();
                }
            }
        }
    }
}
