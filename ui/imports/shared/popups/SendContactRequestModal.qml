import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.stores 1.0 as AppLayoutStores

CommonContactDialog {
    id: root

    property string labelText: qsTr("Why should they accept your contact request?")
    property string challengeText: qsTr("Write a short message telling them who you are...")
    property string buttonText: qsTr("Send contact request")

    signal accepted(string message)

    title: qsTr("Send contact request")

    readonly property int maxMsgLength: 280
    readonly property int minMsgLength: 1
    readonly property int msgHeight: 152

    StatusInput {
        id: messageInput
        input.edit.objectName: "ProfileSendContactRequestModal_sayWhoYouAreInput"
        Layout.fillWidth: true
        label: root.labelText
        charLimit: root.maxMsgLength
        placeholderText: root.challengeText
        input.multiline: true
        minimumHeight: root.msgHeight
        maximumHeight: root.msgHeight
        input.verticalAlignment: TextEdit.AlignTop
        validators: StatusMinLengthValidator {
            minLength: root.minMsgLength
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
