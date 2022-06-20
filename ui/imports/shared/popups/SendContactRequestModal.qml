import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: root

    signal accepted(string message)

    property alias topComponent: topComponentLoader.sourceComponent

    QtObject {
        id: d

        readonly property int maxMsgLength: 280
        readonly property int minMsgLength: 1
        readonly property int msgHeight: 152
        readonly property int contentSpacing: 5
        readonly property int contentMargins: 16
    }

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: d.contentMargins
        spacing: d.contentSpacing

        Loader {
            id: topComponentLoader
            Layout.fillWidth: true
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
            root.accepted(messageInput.text);
            root.close();
        }
    }
}