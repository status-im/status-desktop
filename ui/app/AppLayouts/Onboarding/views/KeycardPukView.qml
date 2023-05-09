import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import utils 1.0

import "../stores"

Item {
    id: root

    property StartupStore startupStore

    property int remainingAttempts: root.startupStore.startupModuleInst.remainingAttempts

    Component.onCompleted: {
        d.allEntriesValid = false
        d.pukArray = Array(d.pukLength)
        d.pukArray.fill("")
    }

    QtObject {
        id: d

        readonly property int pukLength: 12
        property var pukArray: []
        property bool allEntriesValid: false
        readonly property int rowSpacing: Style.current.padding

        function updateValidity() {
            for(let i = 0; i < pukLength; ++i) {
                if(pukArray[i].length !== 1) {
                    allEntriesValid = false
                    return
                }
            }
            allEntriesValid = true
        }

        function submitPuk() {
            let puk = d.pukArray.join("")
            root.startupStore.setPuk(puk)
            root.startupStore.doPrimaryAction()
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        height: Constants.onboarding.loginHeight
        spacing: Style.current.bigPadding

        StatusBaseText {
            id: title
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Constants.keycard.general.fontSize1
            font.weight: Font.Bold
            color: Theme.palette.directColor1
            text: qsTr("Enter PUK code to recover Keycard")
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        RowLayout {
            id: rowLayout
            Layout.alignment: Qt.AlignHCenter
            spacing: d.rowSpacing

            Component.onCompleted: {
                for (var i = 0; i < children.length - 1; ++i) {
                    if(children[i] && children[i].input && children[i+1] && children[i+1].input){
                        children[i].input.tabNavItem = children[i+1].input.edit
                    }
                }
                if(children.length > 0){
                    children[0].input.edit.forceActiveFocus()
                }
            }

            Repeater {
                model: d.pukLength
                delegate: StatusInput {
                    Layout.preferredWidth: Constants.keycard.general.pukCellWidth
                    Layout.preferredHeight: Constants.keycard.general.pukCellHeight
                    input.acceptReturn: true
                    validators: [
                        StatusRegularExpressionValidator {
                            regularExpression: /[0-9]/
                            errorMessage: ""
                        },
                        StatusMinLengthValidator {
                            minLength: 1
                            errorMessage: ""
                        }
                    ]

                    onTextChanged: {
                        text = text.trim()
                        if(text.length >= 1) {
                            text = text.charAt(0);
                        }
                        if(Utils.isDigit(text)) {
                            let nextInd = index+1
                            if(nextInd <= rowLayout.children.length - 1 &&
                                    rowLayout.children[nextInd] &&
                                    rowLayout.children[nextInd].input){
                                rowLayout.children[nextInd].input.edit.forceActiveFocus()
                            }
                        }
                        else                            {
                            text = ""
                        }
                        d.pukArray[index] = text
                        d.updateValidity()
                    }

                    onKeyPressed: {
                        if(input.edit.keyEvent === Qt.Key_Backspace){
                            if (text == ""){
                                let prevInd = index-1
                                if(prevInd >= 0){
                                    rowLayout.children[prevInd].input.edit.forceActiveFocus()
                                }
                            }
                        }
                        else if (input.edit.keyEvent === Qt.Key_Return ||
                                 input.edit.keyEvent === Qt.Key_Enter) {
                            if(d.allEntriesValid) {
                                event.accepted = true
                                d.submitPuk()
                            }
                        }
                    }
                }
            }
        }

        StatusBaseText {
            id: info
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Constants.keycard.general.fontSize3
            color: Theme.palette.dangerColor1
            horizontalAlignment: Qt.AlignHCenter
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        StatusButton {
            Layout.alignment: Qt.AlignHCenter
            enabled: d.allEntriesValid
            text: qsTr("Recover Keycard")
            onClicked: {
                d.submitPuk()
            }
        }
    }

    states: [
        State {
            name: Constants.startupState.keycardEnterPuk
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardEnterPuk
            PropertyChanges {
                target: info
                text: ""
            }
        },
        State {
            name: Constants.startupState.keycardWrongPuk
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardWrongPuk
            PropertyChanges {
                target: info
                text: qsTr("Invalid PUK code, %n attempt(s) remaining", "", root.remainingAttempts)
            }
            StateChangeScript {
                script: d.allEntriesValid = false
            }
        }
    ]
}
