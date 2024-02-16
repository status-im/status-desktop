import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups.Dialog 0.1

CommonContactDialog {
    id: root

    property var rootStore

    property string labelText: qsTr("Why should they accept your contact request?")
    property string challengeText: qsTr("Write a short message telling them who you are...")
    property string buttonText: qsTr("Send contact request")

    signal accepted(string message)

    title: qsTr("Send Contact Request")

    onAboutToShow: {
        messageInput.input.edit.forceActiveFocus()

        // (request) update from mailserver
        if (d.userDisplayName === "") {
            root.rootStore.contactStore.requestContactInfo(root.publicKey)
            d.loadingContactDetails = true
        }
    }

    readonly property var d: QtObject {
        id: d

        readonly property int maxMsgLength: 280
        readonly property int minMsgLength: 1
        readonly property int msgHeight: 152

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

    readonly property var _conn: Connections {
        target: root.rootStore.contactStore.contactsModule

        function onContactInfoRequestFinished(publicKey, ok) {
            if (publicKey !== root.publicKey)
                return
            if (ok)
                d.contactDetails = Utils.getContactDetailsAsJson(root.publicKey, false)
            d.loadingContactDetails = false
        }
    }

    StatusInput {
        id: messageInput
        input.edit.objectName: "ProfileSendContactRequestModal_sayWhoYouAreInput"
        Layout.fillWidth: true
        label: root.labelText
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

    rightButtons: ObjectModel {
        StatusFlatButton {
            text: qsTr("Cancel")
            onClicked: root.close()
        }
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
