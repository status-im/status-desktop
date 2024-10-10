import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import utils 1.0

import AppLayouts.Profile.stores 1.0 as ProfileStores

CommonContactDialog {
    id: root

    property string senderPublicKey: ""
    property string challengeText: ""
    property string responseText: ""
    property double messageTimestamp: 0
    property double responseTimestamp: 0

    signal verificationRefused()
    signal responseSent(string response)

    title: qsTr("Reply to ID verification request")

    onAboutToShow: {
        verificationResponse.input.edit.forceActiveFocus()
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: msgColumn.implicitHeight + msgColumn.anchors.topMargin + msgColumn.anchors.bottomMargin
        color: "transparent"
        border.width: 1
        border.color: Theme.palette.baseColor2
        radius: Style.current.radius

        ColumnLayout {
            id: msgColumn
            anchors.fill: parent
            anchors.margins: Style.current.padding

            StatusTimeStampLabel {
                Layout.fillWidth: true
                timestamp: root.messageTimestamp
            }
            StatusBaseText {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: root.challengeText
            }
        }
    }

    StatusInput {
        id: verificationResponse
        input.multiline: true
        label: qsTr("Your answer")
        placeholderText: qsTr("Write your answer...")
        minimumHeight: 152
        maximumHeight: 152
        input.verticalAlignment: TextEdit.AlignTop
        charLimit: 280
        Layout.fillWidth: true
        Layout.topMargin: Style.current.padding
    }

    rightButtons: ObjectModel {
        StatusButton {
            text: qsTr("Decline")
            type: StatusBaseButton.Type.Danger
            objectName: "refuseVerificationButton"
            onClicked: {
                root.verificationRefused()
                root.close()
            }
        }
        StatusButton {
            text: qsTr("Send reply")
            type: StatusBaseButton.Type.Success
            objectName: "sendAnswerButton"
            enabled: verificationResponse.text !== ""
            onClicked: {
                root.responseSent(SQUtils.StringUtils.escapeHtml(verificationResponse.text))
                root.responseText = verificationResponse.text
                root.responseTimestamp = Date.now()
                root.close()
            }
        }
    }
}
