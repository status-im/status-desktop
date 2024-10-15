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

    required property ProfileStores.ContactsStore contactsStore

    signal verificationRefused(string senderPublicKey)
    signal responseSent(string senderPublicKey, string response)

    function updateVerificationDetails() {
        try {
            const request = root.contactsStore.getVerificationDetailsFromAsJson(root.publicKey)

            if (request.requestStatus === Constants.verificationStatus.canceled) {
                root.close()
            }

            d.senderPublicKey = request.from
            d.challengeText = request.challenge
            d.responseText = request.response
            d.messageTimestamp = request.requestedAt
        } catch (e) {
            console.error("Error getting or parsing verification data", e)
        }
    }

    readonly property var _con: Connections {
        target: root.contactsStore.receivedContactRequestsModel ?? null

        function onItemChanged(pubKey) {
            if (pubKey === root.publicKey)
                root.updateVerificationDetails()
        }
    }

    readonly property var d: QtObject {
        id: d

        property string senderPublicKey
        property string challengeText
        property string responseText
        property double messageTimestamp
        property double responseTimestamp
    }

    title: qsTr("Reply to ID verification request")

    onAboutToShow: {
        root.updateVerificationDetails()
        verificationResponse.input.edit.forceActiveFocus()
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: msgColumn.implicitHeight + msgColumn.anchors.topMargin + msgColumn.anchors.bottomMargin
        color: "transparent"
        border.width: 1
        border.color: Theme.palette.baseColor2
        radius: Theme.radius

        ColumnLayout {
            id: msgColumn
            anchors.fill: parent
            anchors.margins: Theme.padding

            StatusTimeStampLabel {
                Layout.fillWidth: true
                timestamp: d.messageTimestamp
            }
            StatusBaseText {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: d.challengeText
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
        Layout.topMargin: Theme.padding
    }

    rightButtons: ObjectModel {
        StatusButton {
            text: qsTr("Decline")
            type: StatusBaseButton.Type.Danger
            objectName: "refuseVerificationButton"
            onClicked: {
                root.verificationRefused(d.senderPublicKey)
                root.close()
            }
        }
        StatusButton {
            text: qsTr("Send reply")
            type: StatusBaseButton.Type.Success
            objectName: "sendAnswerButton"
            enabled: verificationResponse.text !== ""
            onClicked: {
                root.responseSent(d.senderPublicKey, SQUtils.StringUtils.escapeHtml(verificationResponse.text))
                d.responseText = verificationResponse.text
                d.responseTimestamp = Date.now()
                root.close()
            }
        }
    }
}
