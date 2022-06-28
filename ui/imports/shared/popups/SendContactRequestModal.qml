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

    signal accepted(string message)

    padding: 16

    QtObject {
        id: d

        readonly property int maxMsgLength: 280
        readonly property int minMsgLength: 1
        readonly property int msgHeight: 152
        readonly property int contentSpacing: 5
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        spacing: d.contentSpacing

        ProfileHeader {
            Layout.fillWidth: true

            displayName: root.userDisplayName
            pubkey: root.userPublicKey
            icon: root.userIcon

            displayNameVisible: false
            pubkeyVisible: false
            imageSize: ProfileHeader.ImageSize.Middle
            editImageButtonVisible: false
        }

        StatusInput {
            id: messageInput
            charLimit: d.maxMsgLength

            input.placeholderText: qsTr("Say who you are / why you want to become a contact...")
            input.multiline: true
            input.implicitHeight: d.msgHeight
            input.verticalAlignment: TextEdit.AlignTop

            validators: StatusMinLengthValidator {
                minLength: d.minMsgLength
                errorMessage: Utils.getErrorMessage(messageInput.errors, qsTr("who are you"))
            }
            validationMode: StatusInput.ValidationMode.Always
            Layout.fillWidth: true
        }
    }

    rightButtons: StatusButton {
        enabled: messageInput.valid
        text: qsTr("Send Contact Request")
        onClicked: {
            root.accepted(Utils.escapeHtml(messageInput.text));
            root.close();
        }
    }
}
