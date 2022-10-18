import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

Item {
    id: root

    property var sharedKeycardModule

    signal validation(bool result)

    QtObject {
        id: d

        property bool allEntriesValid: false

        function processText(text) {
            if(text.length === 0)
                return ""
            if(/(^\s|^\r|^\n)|(\s$|^\r$|^\n$)/.test(text)) {
                return text.trim()
            }
            else if(/\s|\r|\n/.test(text)) {
                return ""
            }
            return text
        }

        function update() {
            let codeEntered = code0.text.length > 0 && code1.text.length > 0

            if (codeEntered && code0.text !== code1.text) {
                errorTxt.text = qsTr("The codes don’t match")
            }
            else {
                errorTxt.text = ""
            }

            d.allEntriesValid = codeEntered && code0.text === code1.text
            if (d.allEntriesValid) {
                root.sharedKeycardModule.setPairingCode(code0.text)
            }
            else {
                root.sharedKeycardModule.setPairingCode("")
            }
            root.validation(d.allEntriesValid)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Style.current.xlPadding
        anchors.bottomMargin: Style.current.halfPadding
        anchors.leftMargin: Style.current.xlPadding
        anchors.rightMargin: Style.current.xlPadding
        spacing: Style.current.padding
        clip: true

        StatusBaseText {
            id: title
            Layout.preferredHeight: Constants.keycard.general.titleHeight
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Enter a new pairing code")
            font.pixelSize: Constants.keycard.general.fontSize1
            font.weight: Font.Bold
            color: Theme.palette.directColor1
        }

        StatusBaseText {
            Layout.preferredWidth: code0.width
            Layout.alignment: Qt.AlignCenter
            text: qsTr("Pairing code")
            font.pixelSize: Constants.keycard.general.fontSize2
            color: Theme.palette.directColor1
        }

        StatusPasswordInput {
            id: code0

            property bool showPassword: false

            Layout.preferredWidth: Constants.keycard.general.keycardPairingCodeInputWidth
            Layout.alignment: Qt.AlignCenter
            placeholderText: qsTr("Enter code")
            echoMode: showPassword ? TextInput.Normal : TextInput.Password
            rightPadding: showHideIcon0.width + showHideIcon0.anchors.rightMargin + Style.current.padding / 2

            onTextChanged: {
                text = d.processText(text)
                d.update()
            }

            onAccepted: {
                if (d.allEntriesValid &&
                        (input.edit.keyEvent === Qt.Key_Return ||
                         input.edit.keyEvent === Qt.Key_Enter)) {
                    event.accepted = true
                    root.sharedKeycardModule.currentState.doPrimaryAction()
                }
            }

            StatusFlatRoundButton {
                id: showHideIcon0
                visible: code0.text !== ""
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 16
                width: 24
                height: 24
                icon.name: code0.showPassword ? "hide" : "show"
                icon.color: Theme.palette.baseColor1

                onClicked: code0.showPassword = !code0.showPassword
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.current.padding
        }

        StatusBaseText {
            Layout.preferredWidth: code1.width
            Layout.alignment: Qt.AlignCenter
            text: qsTr("Confirm pairing code")
            font.pixelSize: Constants.keycard.general.fontSize2
            color: Theme.palette.directColor1
        }

        StatusPasswordInput {
            id: code1

            property bool showPassword: false

            Layout.preferredWidth: Constants.keycard.general.keycardPairingCodeInputWidth
            Layout.alignment: Qt.AlignCenter
            placeholderText: qsTr("Confirm code")
            echoMode: showPassword ? TextInput.Normal : TextInput.Password
            rightPadding: showHideIcon1.width + showHideIcon1.anchors.rightMargin + Style.current.padding / 2

            onTextChanged: {
                text = d.processText(text)
                d.update()
            }

            onAccepted: {
                if (d.allEntriesValid &&
                        (input.edit.keyEvent === Qt.Key_Return ||
                         input.edit.keyEvent === Qt.Key_Enter)) {
                    event.accepted = true
                    root.sharedKeycardModule.currentState.doPrimaryAction()
                }
            }

            StatusFlatRoundButton {
                id: showHideIcon1
                visible: code1.text !== ""
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 16
                width: 24
                height: 24
                icon.name: code1.showPassword ? "hide" : "show"
                icon.color: Theme.palette.baseColor1

                onClicked: code1.showPassword = !code1.showPassword
            }
        }

        StatusBaseText {
            id: errorTxt
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            font.pixelSize: Constants.keycard.general.fontSize3
            color: Theme.palette.dangerColor1
        }
    }
}
