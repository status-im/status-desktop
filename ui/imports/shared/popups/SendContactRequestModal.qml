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

    property string userPublicKey: ""
    property string userDisplayName: ""
    property string userIcon: ""
    property bool userIsEnsVerified

    property string challengeText: qsTr("Say who you are / why you want to become a contact...")
    property string buttonText: qsTr("Send Contact Request")

    signal accepted(string message)

    width: 480
    height: 548

    header.title: qsTr("Send Contact Request to %1").arg(userDisplayName)

    QtObject {
        id: d

        readonly property int maxMsgLength: 280
        readonly property int minMsgLength: 1
        readonly property int msgHeight: 152
        readonly property int contentSpacing: Style.current.halfPadding
    }

    onAboutToShow: {
        messageInput.input.edit.forceActiveFocus()
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

            displayName: root.userDisplayName
            pubkey: root.userPublicKey
            icon: root.userIcon
            userIsEnsVerified: root.userIsEnsVerified

            displayNameVisible: true
            pubkeyVisible: true
            imageSize: ProfileHeader.ImageSize.Middle
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

        Item { Layout.fillHeight: true }
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
