import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0
import shared.controls.chat 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: root

    property var rootStore

    property string userPublicKey: ""
    property string userDisplayName: ""
    property string userIcon: ""
    property bool userIsEnsVerified

    property string challengeText: qsTr("Say who you are / why you want to become a contact...")
    property string buttonText: qsTr("Send Contact Request")

    signal accepted(string message)

    width: 480
    height: 548

    headerSettings.title: d.loadingContactDetails ? qsTr("Send Contact Request")
                                          : qsTr("Send Contact Request to %1").arg(d.userDisplayName)

    onAboutToShow: {
        messageInput.input.edit.forceActiveFocus()

        const contactDetails = Utils.getContactDetailsAsJson(userPublicKey, false)

        if (contactDetails.displayName !== "") {
            d.updateContactDetails(contactDetails)
            return
        }

        root.rootStore.contactStore.requestContactInfo(root.userPublicKey)
        d.loadingContactDetails = true
    }

    QtObject {
        id: d

        readonly property int maxMsgLength: 280
        readonly property int minMsgLength: 1
        readonly property int msgHeight: 152
        readonly property int contentSpacing: Style.current.halfPadding

        property bool loadingContactDetails: false

        property string userDisplayName: ""
        property string userIcon: ""
        property bool userIsEnsVerified

        function updateContactDetails(contactDetails) {
            d.userDisplayName = contactDetails.displayName
            d.userIcon = contactDetails.largeImage
            d.userIsEnsVerified = contactDetails.ensVerified
        }
    }

    Connections {
        target: root.rootStore.contactStore.contactsModule

        function onContactInfoRequestFinished(publicKey, ok) {
            if (ok) {
                const details = Utils.getContactDetailsAsJson(userPublicKey, false)
                d.updateContactDetails(details)
            }
            d.loadingContactDetails = false
        }
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.topMargin: Style.current.bigPadding
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
        spacing: d.contentSpacing

        ProfileHeader {
            Layout.fillWidth: true

            displayName: d.userDisplayName
            pubkey: root.userPublicKey
            icon: d.userIcon
            userIsEnsVerified: d.userIsEnsVerified

            displayNameVisible: true
            pubkeyVisible: true
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

    rightButtons: StatusButton {
        objectName: "ProfileSendContactRequestModal_sendContactRequestButton"
        enabled: messageInput.valid
        text: root.buttonText
        onClicked: {
            root.accepted(messageInput.text);
            root.close();
        }
    }
}
